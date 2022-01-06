// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/// @title YobotDeadline
/// @author Andreas Bigger <andreas@nascent.xyz>
/// @notice Adapted from Numerai's Deadline.sol at
///         https://github.com/numerai/tournament-contracts
/// @notice Deadline cannot be changed after it's passed
contract Deadline {
    uint256 private _deadline;

    event DeadlineSet(uint256 indexed deadline);

    /// @dev constructor takes an initial deadline
    /// @param _initialDeadline the initial deadline value
    constructor(uint256 _initialDeadline) {
        _deadline = _initialDeadline;
    }

    /// @notice sets the deadline
    /// @param deadline the new deadline
    function _setDeadline(uint256 deadline) internal {
        // CHECKS
        require(!isAfterDeadline(), "IMMUTABLE_PASSED_DEADLINE");
        require(deadline > block.timestamp, "PAST_DEADLINE");

        // EFFECTS
        _deadline = deadline;
        emit DeadlineSet(deadline);
    }

    /// @notice gets the current deadline
    /// @return deadline
    function getDeadline() public view returns (uint256 deadline) {
        return _deadline;
    }

    /// @notice checks if deadline is past
    /// @return status whether the deadline is passed or not
    function isAfterDeadline() public view returns (bool status) {
        return block.timestamp >= _deadline;
    }
}