// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

interface IArtBlocksFactory {
    function tokenIdToProjectId(uint256 _tokenId) external view returns (uint256 projectId);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}