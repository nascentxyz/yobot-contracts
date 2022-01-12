// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721} from "solmate/tokens/ERC721.sol";

/// @title StrictMint
/// @dev A restricted mint
/// @author Andreas Bigger <andreas@nascent.xyz>
contract StrictMint is ERC721 {
    /// @dev Base URI
    string private baseURI;

    /// @dev OpenSea Config
    address private openSeaProxyRegistryAddress;
    bool private isOpenSeaProxyActive = true;

    /// @notice The maximum number of nfts to mint
    uint256 public constant MAXIMUM_COUNT = 2000;

    /// @notice The maximum number of tokens to mint per wallet
    uint256 public constant MAX_TOKENS_PER_WALLET = 5;




    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);
    }
}