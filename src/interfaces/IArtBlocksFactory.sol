// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

/// @title ArtBlocksFactory Contract Interface
/// @author Andreas Bigger <andreas@nascent.xyz>
interface IArtBlocksFactory {
    /// @dev Maps a Token ID to a Project ID
    /// @param _tokenId The token id
    /// @return projectId The project id that maps to the inputed token id
    function tokenIdToProjectId(uint256 _tokenId)
        external
        view
        returns (uint256 projectId);

    /// @dev Safely Transfers a given token
    /// @dev Requires the sender to be approved through an `approve` or `setApprovalForAll`
    /// @dev Emits a Transfer Event
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
