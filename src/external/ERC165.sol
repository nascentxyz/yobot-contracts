// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import "../interfaces/IERC165.sol";

/// @title Minimal ERC165 Implementation
/// @dev https://eips.ethereum.org/EIPS/eip-165
/// @author Andreas Bigger <andreas@nascent.xyz>
abstract contract ERC165 is IERC165 {
    /// @dev Returns if the contract implements the defined interface
    /// @param interfaceId the 4 byte interface signature
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return type(IERC165).interfaceId == interfaceId;
    }
}
