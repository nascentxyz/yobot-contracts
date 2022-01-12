// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

/// @title AccessControl
/// @author Andreas Bigger, Artbotter
/// @notice An access controller for Yobot Contracts
contract AccessControl {
  address private admin;
  mapping (address => bool) private operators;

  event OperatorToggled(address indexed operator, bool active);
  event AdminTransferred(address oldAdmin, address newAdmin);

  constructor() {
    admin = msg.sender;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin, "NON_ADMIN");
    _;
  }

  modifier onlyOperator() {
    require(isOperator(msg.sender), "NON_OPERATOR");
    _;
  }

  function toggleOperators(address[] calldata _operators) external onlyAdmin {
    for (uint256 i; i < _operators.length; i++) {
      bool newStatus = !operators[_operators[i]];
      operators[_operators[i]] = newStatus;
      emit OperatorToggled(_operators[i], newStatus);
    }
  }

  function transferAdmin(address _newAdmin) external onlyAdmin {
    address oldAdmin = admin;
    admin = _newAdmin;
    emit AdminTransferred(oldAdmin, _newAdmin);
  }

  function getAdmin() external view returns (address) {
    return admin;
  }

  function isOperator(address _addr) public view returns (bool) {
    return operators[_addr];
  }
}