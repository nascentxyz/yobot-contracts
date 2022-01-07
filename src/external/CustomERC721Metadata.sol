// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC165} from "openzeppelin-contracts/utils/introspection/ERC165.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

import {ERC721Enumerable} from "./ERC721Enumerable.sol";

/**
 * ERC721 base contract without the concept of tokenUri as this is managed by the parent
 */
contract CustomERC721Metadata is ERC165, ERC721, ERC721Enumerable {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor(string memory argName, string memory argSymbol) ERC721(argName, argSymbol) {
        _name = argName;
        _symbol = argSymbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        // ?? Changed `_registerInterface` to `supportsInterface` ??
        supportsInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice use ERC721Enumerable definition
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @notice use ERC721Enumerable definition
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, ERC721, ERC721Enumerable) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }
}