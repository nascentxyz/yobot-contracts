// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {YobotArtBlocksBroker} from "../YobotArtBlocksBroker.sol";

// Import a mock NFT token to test bot functionality
import {InfiniteMint} from "../mocks/InfiniteMint.sol";

contract YobotArtBlocksBrokerTest is DSTestPlus {
    YobotArtBlocksBroker public yabb;

    /// @dev coordination logic
    address public profitReceiver = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B; // VB, a burn address (:
    uint32 public botFeeBips = 5_000; // 50% 

    /// @dev The bot
    address public bot = 0x6C0439f659ABbd2C52A61fBf5bE36f5ad43d08a4; // legendary mev bot

    /// @dev A Mock NFT
    InfiniteMint public infiniteMint;

    /// @notice testing suite precursors
    function setUp() public {
        infiniteMint = new InfiniteMint("Mock NFT", "MOCK");
        yabb = new YobotArtBlocksBroker(profitReceiver, botFeeBips);
        // Sanity check on the coordinator
        assert(yabb.coordinator() == address(this));
    }

    ////////////////////////////////////////////////////
    ///                ORDER PLACEMENT               ///
    ////////////////////////////////////////////////////

    /// @notice Test can't place order when Artblocks Project Id is 0
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _quantity the number of erc721 tokens
    function testFailPlaceZeroProjectIdOrder(uint256 _value, uint128 _quantity)
        public
    {
        // this should fail
        yabb.placeOrder{value: _value}(0, _quantity);
    }

    /// @notice Test fails to place duplicate orders for the same artblocks project
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _artBlocksProjectId the ArtBlocks Project Id
    /// @param _quantity the number of erc721 tokens
    function testFailPlaceDuplicateOrder(
        uint256 _value,
        uint256 _artBlocksProjectId,
        uint128 _quantity
    ) public {
        require(_artBlocksProjectId > 0, "ID_CANNOT_BE_ZERO");
        yabb.placeOrder{value: _value}(_artBlocksProjectId, _quantity);
        // this should fail with `DUPLICATE_ORDER` since order.quantity * order.priceInWeiEach
        yabb.placeOrder{value: _value}(_artBlocksProjectId, _quantity);
    }

    /// @notice Test fail to send placeOrder from a contract - not an EOA
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _artBlocksProjectId the ArtBlocks Project Id
    /// @param _quantity the number of erc721 tokens
    function testFailPlaceOrderFromContract(
        uint256 _value,
        uint256 _artBlocksProjectId,
        uint128 _quantity
    ) public {
        // this should fail with `NOT_EOA`
        yabb.placeOrder{value: _value}(_artBlocksProjectId, _quantity);
    }

    /// @notice Test can place order
    // function testPlaceOrder(uint256 _value, uint256 _artBlocksProjectId, uint128 _quantity) public {
    //     if (_artBlocksProjectId > 0) {
    //         yabb.placeOrder{value: _value}(_artBlocksProjectId, _quantity);
    //     }
    // }

    ////////////////////////////////////////////////////
    ///              ORDER CANCELLATION              ///
    ////////////////////////////////////////////////////

    /// @notice Test user can't cancel unplaced order
    /// @param _artBlocksProjectId Artblocks Project Id
    function testFailCancelUnplacedOrder(uint256 _artBlocksProjectId) public {
        require(_artBlocksProjectId != 0, "INVALID_ARTBLOCKS_ID");
        // this should fail with `ORDER_NOT_FOUND`
        yabb.cancelOrder(_artBlocksProjectId);
    }

    /// @notice Test user can't cancel an order with Artblocks Project Id = 0
    function testFailCancelZeroProjectIdOrder() public {
        yabb.cancelOrder(0);
    }

    /// @notice user can't cancel duplicate orders
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _artBlocksProjectId the ArtBlocks Project Id
    /// @param _quantity the number of erc721 tokens
    function testFailCancelDuplicateOrder(
        uint256 _value,
        uint256 _artBlocksProjectId,
        uint128 _quantity
    ) public {
        require(_artBlocksProjectId != 0, "NONEXISTANT_ORDER");
        yabb.placeOrder{value: _value}(_artBlocksProjectId, _quantity);
        yabb.cancelOrder(_artBlocksProjectId);
        // this should fail with `ORDER_NOT_FOUND`
        yabb.cancelOrder(_artBlocksProjectId);
    }

    // TODO: cancel an order, we can't place an order since eoa

    /// @notice can cancel outstanding order
    // /// @param _value value to send - _value = price per nft * _quantity
    // /// @param _artBlocksProjectId the ArtBlocks Project Id
    // /// @param _quantity the number of erc721 tokens
    // function testCancelOrder(
    //     uint256 _value,
    //     uint256 _artBlocksProjectId,
    //     uint128 _quantity
    // ) public {
    //     yabb.placeOrder{value: _value}(_artBlocksProjectId, _quantity);
    //     require(_artBlocksProjectId != 0, "NONEXISTANT_ORDER");
    //     yabb.cancelOrder(_artBlocksProjectId);
    //     // this should fail with `ORDER_NOT_FOUND`
    //     yabb.cancelOrder(_artBlocksProjectId);
    // }

    ////////////////////////////////////////////////////
    ///                  BOT LOGIC                   ///
    ////////////////////////////////////////////////////

    /// @notice Bot can fill an order
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _quantity the number of erc721 tokens
    function testFillOrder(
        uint256 _value,
        uint128 _quantity
    ) public {
        // Mint the bot some NFTs
        infiniteMint.mint(bot, 1);

        // Place an order
        // yabb.placeOrder{value: _value}(address(infiniteMint), _quantity);
        
        // Bot can fill order
        // yabb.fillOrder(address(this), address(infiniteMint), 1, _value, bot, true);

        // Burn the minted erc721 so we don't conflict inter-tests
        infiniteMint.burn(1);
    }

    ////////////////////////////////////////////////////
    ///                 WITHDRAWALS                  ///
    ////////////////////////////////////////////////////

    // function testWithdrawal() public {
    //     yabb.withdraw();
    // }
}
