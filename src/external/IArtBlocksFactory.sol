// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IArtBlocksFactory {
    function tokenIdToProjectId(uint256 _tokenId) external view returns (uint256 projectId);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}