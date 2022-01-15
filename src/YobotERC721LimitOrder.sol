// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {IERC721} from "./interfaces/IERC721.sol";
import {Coordinator} from "./Coordinator.sol";

/// Require EOA
/// @param sender The msg sender
/// @param origin The transaction origin
error NonEOA(address sender, address origin);

/// Order Out of Bounds
/// @param user The address of the user
/// @param orderNumber The requested order number for the user (maps to an order id)
/// @param maxOrderCount The maximum number of orders a user has placed
error OrderOOB(address user, uint256 orderNumber, uint256 maxOrderCount);

/// Order Nonexistent
/// @param user The address of the user
/// @param orderNumber The requested order number for the user (maps to an order id)
/// @param orderId The order's Id
error OrderNonexistent(address user, uint256 orderNumber, uint256 orderId);

/// Invalid Amount
/// @param sender The address of the msg sender
/// @param priceInWeiEach The order's priceInWeiEach
/// @param quantity The order's quantity
/// @param tokenAddress The order's token address
error InvalidAmount(address sender, uint256 priceInWeiEach, uint256 quantity, address tokenAddress);

/// @title YobotERC721LimitOrder
/// @author Andreas Bigger <andreas@nascent.xyz>
/// @notice Original contract implementation was open-sourced and verified on etherscan at:
///         https://etherscan.io/address/0x56E6FA0e461f92644c6aB8446EA1613F4D72a756#code
///         with the original UI at See ArtBotter.io
/// @notice Permissionless Broker for Generalized ERC721 Minting using Flashbot Searchers
contract YobotERC721LimitOrder is Coordinator {
    /// @notice A user's order
    struct Order {
        /// @dev The Order's Token Address
        address tokenAddress;
        /// @dev the price to pay for each erc721 token
        uint256 priceInWeiEach;
        /// @dev the quantity of tokens to pay
        uint256 quantity;
    }

    /// @dev Current Order Id
    /// @dev Starts at 1, 0 is a deleted order
    uint256 public orderId = 1;

    /// @dev Mapping from order id to an Order
    mapping(uint256 => Order) orderStore;

    /// @dev user => order number => order id
    mapping(address => mapping(uint256 => uint256)) public userOrders;

    /// @dev The number of user orders
    mapping(address => uint256) public userOrderCount;

    /// @dev bot => eth balance
    mapping(address => uint256) public balances;

    /// @notice Emitted whenever a respective individual executes a function
    /// @param _user the address of the sender executing the action - used primarily for indexing
    /// @param _tokenAddress The token address to interact with
    /// @param _priceInWeiEach The bid price in wei for each ERC721 Token
    /// @param _quantity The number of tokens
    /// @param _action The action being emitted
    /// @param _orderNum The Id for the user's order
    event Action(
        address indexed _user,
        address indexed _tokenAddress,
        uint256 indexed _priceInWeiEach,
        uint256 indexed _quantity,
        string _action,
        uint256 _orderNum
    );

    /// @notice Creates a new yobot erc721 limit order broker
    /// @param _profitReceiver The profit receiver for fees
    /// @param _botFeeBips The fee rake
    // solhint-disable-next-line no-empty-blocks
    constructor(address _profitReceiver, uint32 _botFeeBips) Coordinator(_profitReceiver, _botFeeBips) {}

    ////////////////////////////////////////////////////
    ///                     ORDERS                   ///
    ////////////////////////////////////////////////////

    /// @notice places an open order for a user
    /// @notice users should place orders ONLY for token addresses that they trust
    /// @param _tokenAddress the erc721 token address
    /// @param _quantity the number of tokens
    function placeOrder(address _tokenAddress, uint256 _quantity) external payable {
        // Removes user foot-guns and garuantees user can receive NFTs
        // We disable linting against tx-origin to purposefully allow EOA checks
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender != tx.origin) revert NonEOA(msg.sender, tx.origin);

        // Check to make sure the bids are gt zero
        uint256 priceInWeiEach = msg.value / _quantity;
        if (priceInWeiEach == 0 || _quantity == 0) revert InvalidAmount(msg.sender, priceInWeiEach, _quantity, _tokenAddress);

        // Update the Order Id
        uint256 currOrderId = orderId;
        orderId += 1;

        // Create a new Order
        orderStore[currOrderId].priceInWeiEach = priceInWeiEach;
        orderStore[currOrderId].quantity = _quantity;
        orderStore[currOrderId].tokenAddress = _tokenAddress;

        // Update the user's orders
        uint256 currUserOrderCount = userOrderCount[msg.sender];
        userOrders[msg.sender][currUserOrderCount] = currOrderId;
        userOrderCount[msg.sender] += 1;

        emit Action(msg.sender, _tokenAddress, priceInWeiEach, _quantity, "ORDER_PLACED", currUserOrderCount);
    }

    /// @notice Cancels a user's order for the given erc721 token
    /// @param _orderNum The user's order number
    function cancelOrder(uint256 _orderNum) external {
        // Check to make sure the user's order is in bounds
        uint256 currUserOrderCount = userOrderCount[msg.sender];
        if (_orderNum >= currUserOrderCount) revert OrderOOB(msg.sender, _orderNum, currUserOrderCount);

        // Get the id for the given user order num
        uint256 currOrderId = userOrders[msg.sender][_orderNum];
        
        // Revert if the order id is 0, already deleted
        if (currOrderId == 0) revert OrderNonexistent(msg.sender, _orderNum, currOrderId);

        // Get the order
        Order memory order = orderStore[currOrderId];
        uint256 amountToSendBack = order.priceInWeiEach * order.quantity;
        if (amountToSendBack == 0) revert InvalidAmount(msg.sender, order.priceInWeiEach, order.quantity, order.tokenAddress);
        
        // Delete the order
        delete orderStore[currOrderId];

        // Delete the order id from the userOrders mapping
        delete userOrders[msg.sender][_orderNum];

        // Send the value back to the user
        sendValue(payable(msg.sender), amountToSendBack);

        emit Action(msg.sender, _tokenAddress, order.priceInWeiEach, order.quantity, "ORDER_CANCELLED", 0);
    }

    ////////////////////////////////////////////////////
    ///                  BOT LOGIC                   ///
    ////////////////////////////////////////////////////

    /// @notice fill a single order
    /// @param _user the address of the user with the order
    /// @param _tokenAddress the address of the erc721 token
    /// @param _tokenId the token id to mint
    /// @param _expectedPriceInWeiEach the price to pay
    /// @param _profitTo the address to send the fee to
    /// @param _sendNow whether or not to send the fee now
    function fillOrder(
        address _user,
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _expectedPriceInWeiEach,
        address _profitTo,
        bool _sendNow
    ) public returns (uint256) {
        // CHECKS
        Order memory order = orders[_user][_tokenAddress];
        require(order.quantity > 0, "NO_OUTSTANDING_USER_ORDER");
        // Protects bots from users frontrunning them
        require(order.priceInWeiEach >= _expectedPriceInWeiEach, "INSUFFICIENT_EXPECTED_PRICE");

        // EFFECTS
        // This reverts on underflow
        orders[_user][_tokenAddress].quantity = order.quantity - 1;
        uint256 botFee = (order.priceInWeiEach * botFeeBips) / 10_000;
        balances[profitReceiver] += botFee;

        // INTERACTIONS
        // Transfer NFT to user (benign reentrancy possible here)
        // ERC721-compliant contracts revert on failure here
        IERC721(_tokenAddress).safeTransferFrom(msg.sender, _user, _tokenId);

        // Pay the bot with the remaining amount
        uint256 botPayment = order.priceInWeiEach - botFee;
        if (_sendNow) {
            sendValue(payable(_profitTo), botPayment);
        } else {
            balances[_profitTo] += botPayment;
        }

        // Emit the action later so we can log trace on a bot dashboard
        emit Action(_user, _tokenAddress, order.priceInWeiEach, order.quantity - 1, "ORDER_FILLED", _tokenId);

        // TODO: delete order ?

        // RETURN
        return botPayment;
    }

    /// @notice allows a bot to fill multiple outstanding orders
    /// @dev there should be one token id and token price specified for each users
    /// @dev So, _users.length == _tokenIds.length == _expectedPriceInWeiEach.length
    /// @param _users a list of users to fill orders for
    /// @param _tokenAddress the address of the erc721 token
    /// @param _tokenIds a list of token ids
    /// @param _expectedPriceInWeiEach the price of each token
    /// @param _profitTo the address to send the bot's profit to
    /// @param _sendNow whether the profit should be sent immediately
    function fillMultipleOrdersOptimized(
        address[] memory _users,
        address _tokenAddress,
        uint256[] memory _tokenIds,
        uint256[] memory _expectedPriceInWeiEach,
        address _profitTo,
        bool _sendNow
    ) external returns (uint256[] memory) {
        require(_users.length == _tokenIds.length && _tokenIds.length == _expectedPriceInWeiEach.length, "ARRAY_LENGTH_MISMATCH");
        uint256[] memory output = new uint256[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            output[i] = fillOrder(_users[i], _tokenAddress, _tokenIds[i], _expectedPriceInWeiEach[i], _profitTo, _sendNow);
        }
        return output;
    }

    /// @notice allows a bot to fill multiple outstanding orders with
    /// @dev all argument array lengths should be equal
    /// @param _users a list of users to fill orders for
    /// @param _tokenAddresses a list of erc721 token addresses
    /// @param _tokenIds a list of token ids
    /// @param _expectedPriceInWeiEach the price of each token
    /// @param _profitTo the addresses to send the bot's profit to
    /// @param _sendNow whether the profit should be sent immediately
    function fillMultipleOrdersUnOptimized(
        address[] memory _users,
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        uint256[] memory _expectedPriceInWeiEach,
        address[] memory _profitTo,
        bool[] memory _sendNow
    ) external returns (uint256[] memory) {
        // verify argument array lengths are equal
        require(_users.length == _tokenAddresses.length && _tokenAddresses.length == _tokenIds.length && _tokenIds.length == _expectedPriceInWeiEach.length && _expectedPriceInWeiEach.length == _profitTo.length && _profitTo.length == _sendNow.length, "ARRAY_LENGTH_MISMATCH");
        uint256[] memory output = new uint256[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            output[i] = fillOrder(_users[i], _tokenAddresses[i], _tokenIds[i], _expectedPriceInWeiEach[i], _profitTo[i], _sendNow[i]);
        }
        return output;
    }

    ////////////////////////////////////////////////////
    ///                 WITHDRAWALS                  ///
    ////////////////////////////////////////////////////

    /// @notice Allows profitReceiver and bots to withdraw their fees
    /// @dev delete balances on withdrawal to free up storage
    function withdraw() external {
        // EFFECTS
        uint256 amount = balances[msg.sender];
        delete balances[msg.sender];
        // INTERACTIONS
        sendValue(payable(msg.sender), amount);
    }

    ////////////////////////////////////////////////////
    ///                   HELPERS                    ///
    ////////////////////////////////////////////////////

    /// @notice sends ETH out of this contract to the recipient
    /// @dev OpenZeppelin's sendValue function
    /// @param recipient the recipient to send the ETH to | payable
    /// @param amount the amount of ETH to send
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /// @notice returns an open order for a given user and token address
    /// @param _user the users address
    /// @param _tokenAddress the address of the token
    function viewOrder(address _user, address _tokenAddress) external view returns (Order memory) {
        return orders[_user][_tokenAddress];
    }

    /// @notice returns the open orders for a given user and list of tokens
    /// @param _users the users address
    /// @param _tokenAddresses a list of token addresses
    function viewOrders(address[] memory _users, address[] memory _tokenAddresses) external view returns (Order[] memory) {
        Order[] memory output = new Order[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) output[i] = orders[_users[i]][_tokenAddresses[i]];
        return output;
    }
}