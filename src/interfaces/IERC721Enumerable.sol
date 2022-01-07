// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import "./IERC721.sol";

/// @title ERC-721 Enumerable Interface
/// @author Andreas Bigger <andreas@nascent.xyz>
interface IERC721Enumerable {
    /// @dev Returns the total amount of tokens stored by the contract.
    function totalSupply() external view returns (uint256);

    /// @dev Returns a token ID owned by `owner` at a given `index` of its token list.
    /// @dev Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /// @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
    /// @dev Use along with {totalSupply} to enumerate all tokens.
    function tokenByIndex(uint256 index) external view returns (uint256);
}
