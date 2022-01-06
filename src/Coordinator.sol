// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Coordinator {
    /// @dev This contracts coordinator
    address public coordinator;

    /// @dev Address of the profit receiver
    address payable public profitReceiver;

    /// @dev Fee paid by bots
    uint256 public botFeeBips;

    /// @dev Modifier restricting msg.sender to solely be the coordinatoooor
    modifier onlyCoordinator() {
        require(msg.sender == coordinator, "not Coordinator");
        _;
    }

    /// @notice generic constructor to set coordinator to the msg.sender
    constructor(address _profitReceiver, uint256 _botFeeBips) {
        coordinator = msg.sender;
        profitReceiver = payable(_profitReceiver);
        require(_botFeeBips <= 500, "fee too high");
        botFeeBips = _botFeeBips;
    }

    /*///////////////////////////////////////////////////////////////
                        COORDINATOR FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function changeCoordinator(address _newCoordinator) external onlyCoordinator {
        coordinator = _newCoordinator;
    }

    function changeProfitReceiver(address _newProfitReceiver) external onlyCoordinator {
        profitReceiver = payable(_newProfitReceiver);
    }

    function changeBotFeeBips(uint256 _newBotFeeBips) external onlyCoordinator {
        require(_newBotFeeBips <= 500, "fee cannot be greater than 5%");
        botFeeBips = _newBotFeeBips;
    }
}