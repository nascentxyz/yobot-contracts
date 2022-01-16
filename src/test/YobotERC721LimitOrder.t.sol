// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {stdCheats} from "@std/stdlib.sol";
import {Vm} from "@std/Vm.sol";

import {YobotERC721LimitOrder} from "../YobotERC721LimitOrder.sol";

// Import a mock NFT token to test bot functionality
import {InfiniteMint} from "../mocks/InfiniteMint.sol";

contract YobotERC721LimitOrderTest is DSTestPlus, stdCheats {
    YobotERC721LimitOrder public ylo;

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);

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
        ylo = new YobotERC721LimitOrder(profitReceiver, botFeeBips);
        // Sanity check the coordinator
        assert(ylo.coordinator() == address(this));
    }

    ////////////////////////////////////////////////////
    ///                ORDER PLACEMENT               ///
    ////////////////////////////////////////////////////

    /// @notice Test fails to place duplicate orders for the same mint
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

    /// @notice Test fails to place orders with zero wei value
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testFailZeroWeiOrder(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        ylo.placeOrder{value: 0}(_tokenAddress, _quantity);
    }

    // TODO: orders need to be placed from an EOA, how to mock

    /// @notice Test can place order
    /// @param _value The amount of wei to send
    /// @param _quantity the number of erc721 tokens
    function testPlaceOrder(uint32 _value, uint128 _quantity) public {
        if(_quantity > 0 && _value >= _quantity) {
            // Uses the `prank` cheatcode to mock msg.sender in a low level call
            // https://github.com/gakonst/foundry/blob/master/evm-adapters/testdata/CheatCodes.sol
            address new_sender = address(1337);
            startHoax(new_sender);
            ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
            vm.stopPrank();
        } else if (_value < _quantity) {
            // This should fail since (price/quantity) == 0
            vm.expectRevert("ZERO_WEI_BID");
            address new_sender = address(1337);
            startHoax(new_sender);
            ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
            vm.stopPrank();
        } else {
            // This should fail since either the quantity is 0
            vm.expectRevert("ZERO_QUANTITY_BID");
            address new_sender = address(1337);
            startHoax(new_sender);
            ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
            vm.stopPrank();
        }
    }

    ////////////////////////////////////////////////////
    ///              ORDER CANCELLATION              ///
    ////////////////////////////////////////////////////

    /// @notice can cancel outstanding order
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testCancelOrder(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        // Revert with an out of bounds if the orderNum is greater than the user's current order count
        vm.expectRevert(abi.encodeWithSignature("OrderOOB(address,uint256,uint256)", address(this), 1, 0));
        ylo.cancelOrder(1);

        // Place the order
        address new_sender = address(1337);
        startHoax(new_sender);
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);
        vm.stopPrank();

        // This should successfully cancel
        // ylo.cancelOrder(0);

        // Expect Revert on an unplaced order
        // vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", address(this), 0, 0));
        // ylo.cancelOrder(0);

        // // Expect Revert on Duplicate Cancels
        // vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", address(this), 0, 1));
        // ylo.cancelOrder(0);
    }

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
        // ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
        
        // Bot can fill order
        // ylo.fillOrder(address(this), address(infiniteMint), 1, _value, bot, true);

        // Burn the minted erc721 so we don't conflict inter-tests
        infiniteMint.burn(1);
    }


    ////////////////////////////////////////////////////
    ///                 WITHDRAWALS                  ///
    ////////////////////////////////////////////////////

    // function testWithdrawal() public {
    //     ylo.withdraw();
    // }

    ////////////////////////////////////////////////////
    ///                   HELPERS                    ///
    ////////////////////////////////////////////////////

    /// @notice Views an Order
    /// @param _user the user who places an order
    /// @param _tokenAddress the token addres
    function xtestViewOrder(
        address _user,
        address _tokenAddress
    ) public {
        // Expect Revert on a nonexistent order
        bytes memory orderNonexistentEncoding = abi.encodePacked(bytes4(keccak256("OrderNonexistent(address,uint256,uint256)")));
        vm.expectRevert(orderNonexistentEncoding);
        YobotERC721LimitOrder.Order memory preorder = ylo.viewUserOrder(_user, 0);
        assert(preorder.priceInWeiEach == 0);
        assert(preorder.quantity == 0);

        // Place an order
        ylo.placeOrder{value: 10}(_tokenAddress, 10);
        
        // The Order should be populated
        YobotERC721LimitOrder.Order memory placedorder = ylo.viewUserOrder(_user, 0);
        assert(placedorder.priceInWeiEach == 1);
        assert(placedorder.quantity == 10);

        // Cancel the Order
        ylo.cancelOrder(0);

        // Expect Revert on order that was deleted (the orderId == 0)
        vm.expectRevert(orderNonexistentEncoding);
        YobotERC721LimitOrder.Order memory postorder = ylo.viewUserOrder(_user, 0);
        assert(postorder.priceInWeiEach == 0);
        assert(postorder.quantity == 0);
    }

    /// @notice Views Multiple Orders
    /// @param _userOne The first user who places an order
    /// @param _userTwo The second user who places an order
    /// @param _tokenAddressOne The first token addres
    /// @param _tokenAddressTwo The second token addres
    function xtestViewOrders(
        address _userOne,
        address _userTwo,
        address _tokenAddressOne,
        address _tokenAddressTwo
    ) public {
        // Without an order, we should get an empty Order struct
        bytes memory orderNonexistentEncoding = abi.encodePacked(bytes4(keccak256("OrderNonexistent(address,uint256,uint256)")));
        vm.expectRevert(orderNonexistentEncoding);
        YobotERC721LimitOrder.Order memory preorder = ylo.viewUserOrder(_userOne, 0);
        assert(preorder.priceInWeiEach == 0);
        assert(preorder.quantity == 0);

        // Place an order from user 1
        ylo.placeOrder{value: 10}(_tokenAddressOne, 10);
        
        // The Order should be populated
        YobotERC721LimitOrder.Order memory placedorder = ylo.viewUserOrder(_userOne, 0);
        assert(placedorder.priceInWeiEach == 1);
        assert(placedorder.quantity == 10);

        // Place An order for user 2
        ylo.placeOrder{value: 10}(_tokenAddressOne, 10);

        // Expect Revert on order that was deleted (the orderId == 0)
        vm.expectRevert(orderNonexistentEncoding);
        YobotERC721LimitOrder.Order memory postorder = ylo.viewUserOrder(_userOne, 0);
        assert(postorder.priceInWeiEach == 0);
        assert(postorder.quantity == 0);
    }
}
