// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

struct Order { // wei per token is: amountDeposited / quantity
    uint128 quantity; // num NFTs the user wants
    uint128 amountDeposited; // wei the user has deposited
}

struct Drop {
    address token; // NFT contract
    uint128 lockStartTime; // timestamp when lock starts
    uint128 lockLength; // in seconds
}

import {IERC721} from "./interfaces/IERC721.sol";


/// @title YobotBrokerV2
/// @author Andreas Bigger, Artbotter
/// @notice Permissionless Minting Broker
contract YobotBrokerV2 is AccessControlled {
    uint128 public constant MAX_LOCK_LENGTH = 4 hours;

    Drop[] public drops;
    mapping (uint256 => mapping (address => Order)) dropIdToUserOrder; // dropId -> user -> order
    uint256 yoBotBalance;

    event DropInfo(uint256 indexed dropIndex, address token, uint128 _lockStartTime, uint128 _lockLength);
    event OrderInfo(uint256 indexed dropIndex, address indexed user, uint128 quantity, uint128 amountDeposited);
    event OrderFilled(uint256 indexed dropIndex, address indexed user, uint256 tokenId);

    // OPERATOR FUNCTIONS

    function createNewDrop(address _token, uint128 _lockStartTime, uint128 _lockLength) external onlyOperator returns (uint256) {
        require(_lockStartTime > block.timestamp, 'bad lock start time');
        require(_lockLength > 0 && _lockLength <= MAX_LOCK_LENGTH, 'bad lock length');

        uint256 index = drops.length;

        Drop memory newDrop;
        newDrop.token = _token;
        newDrop.lockStartTime = _lockStartTime;
        newDrop.lockLength = _lockLength;

        drops.push(newDrop);

        emit DropInfo(index, _token, _lockStartTime, _lockLength);

        return index;
    }

    function changeLockStartTime(uint256 _dropId, uint128 _newLockStartTime) external onlyOperator {
        Drop storage drop = drops[_dropId];
        require(isBeforeLockStartTime(drop), 'cannot change lock start time after lock has started');
        require(_newLockStartTime >= drop.lockStartTime, 'cannot move locktime backwards');
        drop.lockStartTime = _newLockStartTime;

        emit DropInfo(_dropId, drop.token, _newLockStartTime, drop.lockLength);
    }

    // unlock early (only when locked)
    function unlockEarly(uint256 _dropId) external onlyOperator {
        Drop storage drop = drops[_dropId];
        require(isLocked(drop), 'drop not locked');
        uint128 newLockLength = uint128(block.timestamp) - drop.lockStartTime;
        drop.lockLength = newLockLength;

        emit DropInfo(_dropId, drop.token, drop.lockStartTime, newLockLength);
    }

    function fillOrder(uint256 _dropId, address _user, uint256 _tokenId) external onlyOperator {
        Drop storage drop = drops[_dropId];
        Order storage order = dropIdToUserOrder[_dropId][_user];

        // EFFECTS
        // memoization
        uint128 amountDeposited = order.amountDeposited;
        uint128 quantity = order.quantity;
        uint128 priceInWeiEach = amountDeposited / quantity;
        // state updates
        order.quantity -= 1; // reverts on underflow
		order.amountDeposited -= priceInWeiEach;
		yoBotBalance += priceInWeiEach; // pay the bot
        // events
		emit OrderFilled(_dropId, _user, _tokenId);
		emit OrderInfo(_dropId, _user, quantity - 1, amountDeposited - priceInWeiEach);

		// INTERACTIONS
		// transfer NFT to user
		IERC721(drop.token).safeTransferFrom(msg.sender, _user, _tokenId); // ERC721-compliant contracts revert on failure here
    }

    function collectPayment() external onlyOperator {
        uint256 amountToCollect = yoBotBalance;
        yoBotBalance = 0;
        sendValue(payable(msg.sender), amountToCollect);
    }

    // USER FUNCTIONS

    function createNewOrder(uint256 _dropId, uint128 _quantity) external payable {
        Drop storage drop = drops[_dropId];
        require(dropIdToUserOrder[_dropId][msg.sender].amountDeposited == 0, 'you already have an order for this drop');
        require(isBeforeLockStartTime(drop), 'orders are locked for this drop');
        require(_quantity > 0, '0 quantity orders not accepted');
        require(msg.value > 0, 'no free NFTs');
        dropIdToUserOrder[_dropId][msg.sender].quantity = _quantity;
        dropIdToUserOrder[_dropId][msg.sender].amountDeposited = uint128(msg.value);

        emit OrderInfo(_dropId, msg.sender, _quantity, uint128(msg.value));
    }

    function cancelOrder(uint256 _dropId) external {
        Drop storage drop = drops[_dropId];
        uint256 amountToReturn = dropIdToUserOrder[_dropId][msg.sender].amountDeposited;
        require(!isLocked(drop), 'orders are locked for this drop');
        delete dropIdToUserOrder[_dropId][msg.sender];

        emit OrderInfo(_dropId, msg.sender, 0, 0);

        sendValue(payable(msg.sender), amountToReturn);
    }

    // HELPERS
    function isBeforeLockStartTime(Drop storage _drop) private view returns (bool) {
        return block.timestamp < _drop.lockStartTime;
    }

    function isLocked(Drop storage _drop) private view returns (bool) {
        return (block.timestamp > _drop.lockStartTime && block.timestamp < _drop.lockStartTime + _drop.lockLength) ? true : false;
    }

    // OpenZeppelin's sendValue function, used for transferring ETH out of this contract
	function sendValue(address payable recipient, uint256 amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");
		// solhint-disable-next-line avoid-low-level-calls, avoid-call-value
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}
} 