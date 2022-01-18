// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {IERC20} from "../interfaces/IERC20.sol";

/// @notice Maximum number of tokens minted
error MaximumMints();

/// @notice Too few tokens remain
error InsufficientTokensRemain(uint256 available);

/// @notice Not enough ether sent to mint
/// @param cost The minimum amount of ether required to mint
/// @param sent The amount of ether sent to this contract
error InsufficientFunds(uint256 cost, uint256 sent);

/// @notice Caller is not the contract owner
error Unauthorized(address sender);

/// @title StrictMint
/// @dev A restricted mint
/// @dev Opensea gasless listings logic adapted from Crypto Covens
/// @dev Ref: https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
/// @author Andreas Bigger <andreas@nascent.xyz>
contract StrictMint is ERC721 {
    /// @dev Base URI
    string public baseURI;

    /// @dev Number of tokens
    uint128 private tokenCount;

    /// @notice The contract Owner
    address public owner;

    /// @notice Sale Active?
    bool public isPublicSaleActive;

    /// @dev OpenSea Config
    address private openSeaProxyRegistryAddress;
    bool private isOpenSeaProxyActive = true;

    /// @notice The maximum number of nfts to mint
    uint256 public constant MAXIMUM_COUNT = 2000;

    /// @notice The maximum number of tokens to mint per wallet
    uint256 public constant MAX_TOKENS_PER_WALLET = 5;

    /// @notice Cost to mint a token
    uint256 public constant PUBLIC_SALE_PRICE = 0.07 ether;

    //////////////////////////////////////////////////
    //                  MODIFIERS                   //
    //////////////////////////////////////////////////

    /// @dev Checks if there are enough tokens left for minting
    modifier canMint(uint256 myTokenCount) {
        if (tokenCount >= MAXIMUM_COUNT) {
            revert MaximumMints();
        }
        if (tokenCount + myTokenCount > MAXIMUM_COUNT) {
            revert InsufficientTokensRemain(MAXIMUM_COUNT - tokenCount);
        }
        _;
    }

    /// @dev Checks if user sent enough ether to mint
    modifier isCorrectPayment(uint256 price, uint256 myTokenCount) {
        if (price * myTokenCount > msg.value) {
            revert InsufficientFunds(price * myTokenCount, msg.value);
        }
        _;
    }

    /// @dev Checks if the message sender is the contract owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    //////////////////////////////////////////////////
    //                 CONSTRUCTOR                  //
    //////////////////////////////////////////////////

    /// @dev Sets the ERC721 Metadata and OpenSea Proxy Registry Address
    constructor(
        // address osProxyRegistryAddress
    ) ERC721("Strict Mint", "STRICT") {
        // openSeaProxyRegistryAddress = osProxyRegistryAddress;
        owner = msg.sender;
    }

    //////////////////////////////////////////////////
    //                  METADATA                    //
    //////////////////////////////////////////////////

    /// @dev Returns the URI for the given token
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, "/", tokenId, ".json"));
    }

    //////////////////////////////////////////////////
    //                MINTING LOGIC                 //
    //////////////////////////////////////////////////

    function mint(address to, uint256 tokenId)
        public
        virtual
        payable
        isCorrectPayment(PUBLIC_SALE_PRICE, 1) // minting 1 token
        canMint(1) // minting 1 token
    {
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId)
        public
        virtual
        payable
        isCorrectPayment(PUBLIC_SALE_PRICE, 1) // minting 1 token
        canMint(1) // minting 1 token
    {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        virtual
        payable
        isCorrectPayment(PUBLIC_SALE_PRICE, 1) // minting 1 token
        canMint(1) // minting 1 token
    {
        _safeMint(to, tokenId, data);
    }

    //////////////////////////////////////////////////
    //                BURNING LOGIC                 //
    //////////////////////////////////////////////////

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    //////////////////////////////////////////////////
    //                 ADMIN LOGIC                  //
    //////////////////////////////////////////////////

    /// @notice Sets the baseURI
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    /// @dev Provided to enable disallowing gasless opensea listings
    /// @dev in case Opensea is comprimised or registry logic changes
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive)
        external
        onlyOwner
    {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    /// @dev Sets if the sale is active
    function setIsPublicSaleActive(bool _isPublicSaleActive)
        external
        onlyOwner
    {
        isPublicSaleActive = _isPublicSaleActive;
    }

    /// @dev Allows the owner to withdraw eth
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /// @dev Allows the owner to withdraw any erc20 tokens sent to this contract
    function withdrawTokens(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    //////////////////////////////////////////////////
    //                 CUSTOM LOGIC                 //
    //////////////////////////////////////////////////

    // TODO: Override this so we can allow opensea proxy accounts for gassless listings
    // function isApprovedForAll(address owner, address operator)
    //     public
    //     view
    //     override
    //     returns (bool)
    // {
    //     // Get a reference to OpenSea's proxy registry contract by instantiating
    //     // the contract using the already existing address.
    //     ProxyRegistry proxyRegistry = ProxyRegistry(
    //         openSeaProxyRegistryAddress
    //     );
    //     if (
    //         isOpenSeaProxyActive &&
    //         address(proxyRegistry.proxies(owner)) == operator
    //     ) {
    //         return true;
    //     }

    //     return super.isApprovedForAll(owner, operator);
    // }


    // @dev Support for EIP 2981 Interface by overriding erc165 supportsInterface
    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
            interfaceId == 0x2a55205a;  // ERC165 Interface ID for ERC2981
    }

    /// @dev Royalter information
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = address(this);
        royaltyAmount = (salePrice * 5) / 100;
    }
}