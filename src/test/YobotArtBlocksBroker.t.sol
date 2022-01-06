// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {YobotArtBlocksBroker} from "../YobotArtBlocksBroker.sol";

contract YobotArtBlocksBrokerTest is DSTestPlus {
    YobotArtBlocksBroker public yabb;

    /// @notice testing suite precursors
    /// @param _profitReceiver the _profitReceiver passed to the Coordinator
    /// @param _botFeeBips the _botFeeBips passed to the Coordinator
    function setUp(address _profitReceiver, uint256 _botFeeBips) public {
        yabb = new YobotArtBlocksBroker(_profitReceiver, _botFeeBips);

        // Sanity check on the coordinator
        assert(yabb.coordinator() == address(this));
    }

    /*///////////////////////////////////////////////////////////////
                        SANITY CHECKS
    //////////////////////////////////////////////////////////////*/

    /// @notice Test can't place order when Artblocks Project Id is 0
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _quantity the number of erc721 tokens
    function testFailPlaceZeroProjectIdOrder(uint256 _value, uint128 _quantity) public {
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

    /*///////////////////////////////////////////////////////////////
                        Order Cancelling
    //////////////////////////////////////////////////////////////*/

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

    /*///////////////////////////////////////////////////////////////
                        WITHDRAW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // function testWithdrawal() public {
    //     yabb.withdraw();
    // }
}