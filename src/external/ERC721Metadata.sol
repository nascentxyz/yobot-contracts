// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {ERC165} from "./ERC165.sol";
import {ERC721Enumerable} from "./ERC721Enumerable.sol";

/// @title ERC721 Metadata
/// @notice An Enumerable ERC721 with Metadata
/// @author Andreas Bigger <andreas@nascent.xyz>
abstract contract ERC721Metadata is ERC165, ERC721, ERC721Enumerable {
 

    /// @dev The interface id of the contract
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /// @dev Initializes name, symbol, and registers the supported interfaces
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        supportsInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /// @dev Hook called before token transfers (including minting and burning)
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    /// @dev Returns if the contract implements the defined interface
    /// @param interfaceId the 4 byte interface signature
    function supportsInterface(bytes4 interfaceId) public pure virtual override(ERC165, ERC721, ERC721Enumerable) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }
}