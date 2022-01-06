// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

interface IERC721 {
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;
}