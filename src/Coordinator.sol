// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

/// Fee Overflow
/// @param sender address that caused the revert
/// @param fee uint256 proposed fee percent
error FeeOverflow(address sender, uint256 fee);

/// @title Coordinator
/// @notice Coordinates fees and receivers
/// @author Andreas Bigger <andreas@nascent.xyz>
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

    /// @notice Constructor sets coordinator, profit receiver, and fee in bips
    /// @param profitReceiver the address of the profit receiver
    /// @param botFeeBips the fee in bips
    constructor(address profitReceiver, uint256 botFeeBips) {
        if (botFeeBips > 10_000) revert FeeOverflow(msg.sender, botFeeBips);
        coordinator = msg.sender;
        profitReceiver = payable(profitReceiver);
        botFeeBips = botFeeBips;
    }

    /*///////////////////////////////////////////////////////////////
                        COORDINATOR FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Coordinator can change the stored Coordinator address
    /// @param newCoordinator The address of the new coordinator
    function changeCoordinator(address newCoordinator) external onlyCoordinator {
        coordinator = newCoordinator;
    }

    /// @notice The Coordinator can change the address that receives the fee profits
    /// @param newProfitReceiver The address of the new profit receiver
    function changeProfitReceiver(address newProfitReceiver) external onlyCoordinator {
        profitReceiver = payable(newProfitReceiver);
    }

    /// @notice The Coordinator can change the fee amount in bips
    /// @param newBotFeeBips The unsigned integer representing the new fee amount in bips
    /// @dev The fee cannot be greater than 100%
    function changeBotFeeBips(uint256 newBotFeeBips) external onlyCoordinator {
        if (newBotFeeBips > 10_000) revert FeeOverflow(msg.sender, newBotFeeBips);
        botFeeBips = newBotFeeBips;
    }
}