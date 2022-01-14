// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

/// Fee Overflow
/// @param sender address that caused the revert
/// @param fee uint256 proposed fee percent
error FeeOverflow(address sender, uint256 fee);

/// Non Coordinator
/// @param sender The coordinator impersonator address
/// @param coordinator The expected coordinator address
error NonCoordinator(address sender, address coordinator);

/// @title Coordinator
/// @notice Coordinates fees and receivers
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Coordinator {
    /// @dev This contracts coordinator
    address public coordinator;

    /// @dev Address of the profit receiver
    address payable public profitReceiver;

    /// @dev Pack the below variables using uint32 values
    /// @dev Fee paid by bots
    uint32 public botFeeBips;

    /// @dev The absolute maximum fee in bips (10,000 bips or 100%)
    uint32 public constant MAXIMUM_FEE = 10_000;

    /// @dev Modifier restricting msg.sender to solely be the coordinatoooor
    modifier onlyCoordinator() {
        if (msg.sender != coordinator) revert NonCoordinator(msg.sender, coordinator);
        _;
    }

    /// @notice Constructor sets coordinator, profit receiver, and fee in bips
    /// @param _profitReceiver the address of the profit receiver
    /// @param _botFeeBips the fee in bips
    /// @dev The fee cannot be greater than 100%
    constructor(address _profitReceiver, uint32 _botFeeBips) {
        if (botFeeBips > MAXIMUM_FEE) revert FeeOverflow(msg.sender, _botFeeBips);
        coordinator = msg.sender;
        profitReceiver = payable(_profitReceiver);
        botFeeBips = _botFeeBips;
    }

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
    function changeBotFeeBips(uint32 newBotFeeBips) external onlyCoordinator {
        if (newBotFeeBips > MAXIMUM_FEE) revert FeeOverflow(msg.sender, newBotFeeBips);
        botFeeBips = newBotFeeBips;
    }
}