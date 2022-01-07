// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {IERC721Enumerable} from "../interfaces/IERC721Enumerable.sol";

/// @title ERC721 with Enumerable Token Ids
/// @author Andreas Bigger <andreas@nascent.xyz>
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    /// @dev Mapping from owner to list of owned token ids
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    /// @dev Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    /// @dev Array of token ids
    uint256[] private _allTokens;

    /// @dev Mapping from token id to position in allTokens
    mapping(uint256 => uint256) private _allTokensIndex;

    /// @dev Returns if the contract implements the defined interface
    /// @param interfaceId the 4 byte interface signature
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Returns a token ID owned by `owner` at a given `index` of its token list.
    /// @dev Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /// @dev Returns the total amount of tokens stored by the contract.
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /// @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
    /// @dev Use along with {totalSupply} to enumerate all tokens.
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /// @dev Hook called before token transfers (including minting and burning)
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /// @dev Adds a token to internal owner stores
    /// @param to address of the new token owner
    /// @param tokenId uint256 token id
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /// @dev Adds a token to internal cumulative stores
    /// @param tokenId uint256 token id to be added
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /// @dev Removes a token from internal owner stores
    /// @param from address of the previous owner
    /// @param tokenId uint256 token id to be removed
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
        
        // Move the last token to the slot of the to-delete token
        _ownedTokens[from][tokenIndex] = lastTokenId;
        
        // Update the moved token's index
        _ownedTokensIndex[lastTokenId] = tokenIndex;

        // Delete the last token
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /// @dev Remove a token from internal cumulative stores
    /// @param tokenId uint256 token id to be removed
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        // Move the last token to the slot of the to-delete token
        _allTokens[tokenIndex] = lastTokenId;

        // Update the moved token's index
        _allTokensIndex[lastTokenId] = tokenIndex;

        // Delete the last token
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
