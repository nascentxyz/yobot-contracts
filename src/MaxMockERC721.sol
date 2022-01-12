// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721Metadata} from "./external/ERC721Metadata.sol";

/// @title MaxMockERC721
/// @author Andreas Bigger <andreas@nascent.xyz>
/// @notice A Mock ERC721 Token with a maximum mint amount for addresses
contract MaxMockERC721 is ERC721Metadata {
    /// @dev the token ids
    uint256 private _tokenIds;

    /// @notice the maximum number of tokens
    uint256 public constant MAXIMUM_TOKENS = 10000;

    /// @notice the maximum number of tokens for each address
    uint256 public constant MAXIMUM_TOKENS_PER_ADDRESS = 5;

    /// @dev developooor
    address private developer;

    /// @dev a mapping of users to how many tokens they minted
    mapping(address => uint256) public tokenCount;

    /// @notice constructs the ERC721
    constructor(address _developer)
        ERC721(
            "MockERC721", // name
            "MOCK" // symbol
        )
    {
        developer = _developer;
    }

    ///////////////////////////////////////
    //           MINT FUNCTION           //
    ///////////////////////////////////////

    function mint() external payable {
        /// CHECKS
        uint256 newToken = _tokenIds;
        require(newToken < MAXIMUM_TOKENS, "OUT_OF_SUPPLY");
        require(msg.value >= 0.001 ether, "PRICE_NOT_MET");
        require(tokenCount[msg.sender] < MAXIMUM_TOKENS_PER_ADDRESS, "ACCOUNT_TOKEN_LIMIT");

        /// EFFECTS
        // Increment the tokenId for the next person that uses it.
        _tokenIds += 1;
        tokenCount[msg.sender] = tokenCount[msg.sender] + 1;

        /// INTERACTIONS
        // The magical function! Assigns the tokenId to the caller's wallet address.
        _safeMint(msg.sender, newToken);

        // Try to send value to the developooor
        (bool _success, ) = payable(developer).call{value: msg.value}("");
        require(_success, "UNSUCCESSFULLY_PAYED_THE_DEVS_:(");
    }
}