// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {YobotERC721LimitOrder} from "../YobotERC721LimitOrder.sol";

contract YobotERC721LimitOrderTest is DSTestPlus {
    YobotERC721LimitOrder public ylo;

    /// @notice testing suite precursors
    /// @param _profitReceiver the _profitReceiver passed to the Coordinator
    /// @param _botFeeBips the _botFeeBips passed to the Coordinator
    function setUp(address _profitReceiver, uint256 _botFeeBips) public {
        ylo = new YobotERC721LimitOrder(_profitReceiver, _botFeeBips);

        // Sanity check on the coordinator
        assert(ylo.coordinator() == address(this));
    }

    /*///////////////////////////////////////////////////////////////
                        SANITY CHECKS
    //////////////////////////////////////////////////////////////*/

    /// @notice Test fails to place duplicate orders for the same artblocks project
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testFailPlaceDuplicateOrder(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
        // this should fail with `DUPLICATE_ORDER` since order.quantity * order.priceInWeiEach
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
    }

    /// @notice Test fail to send placeOrder from a contract - not an EOA
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testFailPlaceOrderFromContract(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        // this should fail with `NOT_EOA`
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
    }

    /// @notice Test can place order
    // function testPlaceOrder(uint256 _value, uint256 _tokenAddress, uint128 _quantity) public {
    //     if (_tokenAddress > 0) {
    //         ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
    //     }
    // }

    /*///////////////////////////////////////////////////////////////
                        Order Cancelling
    //////////////////////////////////////////////////////////////*/

    /// @notice Test user can't cancel unplaced order
    /// @param _tokenAddress ERC721 Token Address
    function testFailCancelUnplacedOrder(address _tokenAddress) public {
        // this should fail with `ORDER_NOT_FOUND`
        ylo.cancelOrder(_tokenAddress);
    }

    /// @notice user can't cancel duplicate orders
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testFailCancelDuplicateOrder(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
        ylo.cancelOrder(_tokenAddress);
        // this should fail with `ORDER_NOT_FOUND`
        ylo.cancelOrder(_tokenAddress);
    }

    /// @notice can cancel outstanding order
    // /// @param _value value to send - _value = price per nft * _quantity
    // /// @param _tokenAddress ERC721 Token Address
    // /// @param _quantity the number of erc721 tokens
    // function testCancelOrder(
    //     uint256 _value,
    //     address _tokenAddress,
    //     uint128 _quantity
    // ) public {
    //     ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
    //     require(_tokenAddress != 0, "NONEXISTANT_ORDER");
    //     ylo.cancelOrder(_tokenAddress);
    //     // this should fail with `ORDER_NOT_FOUND`
    //     ylo.cancelOrder(_tokenAddress);
    // }

    /*///////////////////////////////////////////////////////////////
                        WITHDRAW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // function testWithdrawal() public {
    //     ylo.withdraw();
    // }
}