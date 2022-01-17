// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {stdCheats, stdError} from "@std/stdlib.sol";
import {Vm} from "@std/Vm.sol";

import {YobotERC721LimitOrder} from "../YobotERC721LimitOrder.sol";

// Import a mock NFT token to test bot functionality
import {InfiniteMint} from "../mocks/InfiniteMint.sol";

contract YobotERC721LimitOrderTest is DSTestPlus, stdCheats {
    YobotERC721LimitOrder public ylo;

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);

    /// @dev coordination logic
    // use VB, a burn address (:, as the profit receiver
    address public profitReceiver = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
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

    /// @notice Fails to place orders with zero wei value
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testExplicitZeroWeiOrder(
        address _tokenAddress,
        uint128 _quantity
    ) public {
        address new_sender = address(1337);
        startHoax(new_sender, new_sender);
        vm.expectRevert(abi.encodeWithSignature("InvalidAmount(address,uint256,uint256,address)", new_sender, 0, _quantity, _tokenAddress));
        ylo.placeOrder{value: 0}(_tokenAddress, _quantity);
        vm.stopPrank();
    }

    /// @notice Fails to place orders with zero quantity
    /// @param _tokenAddress ERC721 Token Address
    function testExplicitZeroQuantityOrder(
        address _tokenAddress
    ) public {
        address new_sender = address(1337);
        startHoax(new_sender, new_sender);
        vm.expectRevert(stdError.divisionError);
        ylo.placeOrder{value: 1}(_tokenAddress, 0);
        vm.stopPrank();
    }

    /// @notice Test can place order
    /// @param _value The amount of wei to send
    /// @param _quantity the number of erc721 tokens
    function testPlaceOrder(uint32 _value, uint128 _quantity) public {
        address new_sender = address(1337);
        startHoax(new_sender, new_sender);
        if(_quantity > 0 && _value >= _quantity) {
            // Uses the `prank` cheatcode to mock msg.sender in a low level call
            // https://github.com/gakonst/foundry/blob/master/evm-adapters/testdata/CheatCodes.sol
            ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
        } else if (_value < _quantity) {
            // This should fail since (price/quantity) == 0
            vm.expectRevert(abi.encodeWithSignature("InvalidAmount(address,uint256,uint256,address)", new_sender, 0, _quantity, address(infiniteMint)));
            ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
        } else {
            // This should fail since either the quantity is 0
            vm.expectRevert(stdError.divisionError);
            ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);
        }
        vm.stopPrank();
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
        // Hoax the sender and tx.origin
        address new_sender = address(1337);
        startHoax(new_sender, new_sender, type(uint256).max);

        // Revert with an out of bounds if the orderNum is greater than the user's current order count
        vm.expectRevert(abi.encodeWithSignature("OrderOOB(address,uint256,uint256)", new_sender, 1, 0));
        ylo.cancelOrder(1);

        // Make sure our arguments are valid
        if(_quantity == 0) _quantity = 1;
        if (_value < _quantity) _value = _quantity;
        if(_tokenAddress == address(0)) _tokenAddress = address(1336);

        // Place the order
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);

        // This should successfully cancel
        ylo.cancelOrder(0);

        // Expect Revert on an unplaced order
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 0, 0));
        ylo.cancelOrder(0);

        // Place the order
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);

        // Stop the Hoax (prank under the hood)
        vm.stopPrank();

        // Expect Revert since our msg.sender is different
        vm.expectRevert(abi.encodeWithSignature("OrderOOB(address,uint256,uint256)", address(this), 0, 0));
        ylo.cancelOrder(0);

        // Stop the prank
        vm.stopPrank();
    }

    ////////////////////////////////////////////////////
    ///                COMPLEX ORDERS                ///
    ////////////////////////////////////////////////////

    /// @notice Tests multiple orders are placed and cancelled
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testMultipleOrdersAndCancellations(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        // Hoax the sender and tx.origin
        address new_sender = address(1337);
        startHoax(new_sender, new_sender, type(uint256).max);

        // Make sure our arguments are valid
        if(_quantity == 0) _quantity = 1;
        if ((_value / 2) < _quantity) _value = 2 * _quantity;
        if(_tokenAddress == address(0)) _tokenAddress = address(1336);

        // Place the order
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);

        // This should successfully cancel
        ylo.cancelOrder(0);

        // Place more orders
        // Make sure we don't overflow uint256
        ylo.placeOrder{value: _value / 2}(_tokenAddress, _quantity);
        ylo.placeOrder{value: _value / 2}(_tokenAddress, _quantity);

        // We should be able to cancel orders 1+2
        ylo.cancelOrder(1);
        ylo.cancelOrder(2);

        // Expect Revert on an unplaced order
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 0, 0));
        ylo.cancelOrder(0);
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 1, 0));
        ylo.cancelOrder(1);
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 2, 0));
        ylo.cancelOrder(2);
        // We should still fail if the order is out of bounds
        vm.expectRevert(abi.encodeWithSignature("OrderOOB(address,uint256,uint256)", new_sender, 3, 3));
        ylo.cancelOrder(3);

        // Stop the Hoax (prank under the hood)
        vm.stopPrank();
    }

    /// @notice Tests multiple orders are placed and cancelled between multiple users
    /// @param _value value to send - _value = price per nft * _quantity
    /// @param _tokenAddress ERC721 Token Address
    /// @param _quantity the number of erc721 tokens
    function testMultipleUsersOrdersAndCancellations(
        uint256 _value,
        address _tokenAddress,
        uint128 _quantity
    ) public {
        // Hoax the sender and tx.origin
        address new_sender = address(1337);
        startHoax(new_sender, new_sender, type(uint256).max);

        // Make sure our arguments are valid
        if(_quantity == 0) _quantity = 1;
        if ((_value / 2) < _quantity) _value = 2 * _quantity;
        if(_tokenAddress == address(0)) _tokenAddress = address(1336);

        // Place the order
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);

        // This should successfully cancel
        ylo.cancelOrder(0);

        // Place more orders
        ylo.placeOrder{value: _value / 2}(_tokenAddress, _quantity);
        ylo.placeOrder{value: _value / 2}(_tokenAddress, _quantity);

        // We should be able to cancel orders 1+2
        ylo.cancelOrder(1);
        ylo.cancelOrder(2);

        // Expect Revert on an unplaced order
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 0, 0));
        ylo.cancelOrder(0);
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 1, 0));
        ylo.cancelOrder(1);
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 2, 0));
        ylo.cancelOrder(2);
        // We should still fail if the order is out of bounds
        vm.expectRevert(abi.encodeWithSignature("OrderOOB(address,uint256,uint256)", new_sender, 3, 3));
        ylo.cancelOrder(3);

        // Stop the Hoax (prank under the hood)
        vm.stopPrank();

        // Hoax the sender and tx.origin
        address new_sender_2 = address(13372);
        startHoax(new_sender_2, new_sender_2, type(uint256).max);

        // Place the order
        ylo.placeOrder{value: _value}(_tokenAddress, _quantity);

        // This should successfully cancel
        ylo.cancelOrder(0);

        // Place more orders
        ylo.placeOrder{value: _value / 2}(_tokenAddress, _quantity);
        ylo.placeOrder{value: _value / 2}(_tokenAddress, _quantity);

        // We should be able to cancel orders 1+2
        ylo.cancelOrder(1);
        ylo.cancelOrder(2);

        // Expect Revert on an unplaced order
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender_2, 0, 0));
        ylo.cancelOrder(0);
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender_2, 1, 0));
        ylo.cancelOrder(1);
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender_2, 2, 0));
        ylo.cancelOrder(2);
        // We should still fail if the order is out of bounds
        vm.expectRevert(abi.encodeWithSignature("OrderOOB(address,uint256,uint256)", new_sender_2, 3, 3));
        ylo.cancelOrder(3);

        // Stop the Hoax (prank under the hood)
        vm.stopPrank();
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
        // Make sure our arguments are valid
        if(_quantity == 0) _quantity = 1;
        if (_value < _quantity) _value = _quantity;

        // Mint the bot some NFTs
        infiniteMint.mint(bot, 1);

        // Hoax the sender and tx.origin
        address new_sender = address(1337);
        startHoax(new_sender, new_sender, type(uint256).max);

        // Expect Revert on unplaced order
        vm.expectRevert(abi.encodeWithSignature("InvalidAmount(address,uint256,uint256,address)", address(0), 0, 0, address(0)));
        ylo.fillOrder(1, 1, _value / _quantity, bot, true);

        // Place an order
        ylo.placeOrder{value: _value}(address(infiniteMint), _quantity);

        vm.stopPrank();

        // Fill order in bot context
        startHoax(bot, bot, type(uint256).max);

        // Expect Revert on bad pricing
        uint256 expectedPriceInWeiEach = (_value / _quantity) + 1;
        vm.expectRevert(
            abi.encodeWithSignature(
                "InsufficientPrice(address,uint256,uint256,uint256,uint256)",
                bot,                        // msg.sender
                1,                          // _orderId
                1,                          // _tokenId
                expectedPriceInWeiEach,     // _expectedPriceInWeiEach
                (_value / _quantity)        // order.priceInWeiEach
            )
        );
        ylo.fillOrder(1, 1, expectedPriceInWeiEach, bot, true);
        
        // This should revert with NOT_AUTHORIZED since the bot hasn't approved ylo per erc721
        vm.expectRevert("NOT_AUTHORIZED");
        ylo.fillOrder(1, 1, _value / _quantity, bot, true);

        // Bot has to approve the tokens to be transfered since it's a safe transfer
        infiniteMint.approve(address(ylo), 1);

        // Bot can fill order
        ylo.fillOrder(1, 1, _value / _quantity, bot, true);

        // Burn the minted erc721
        infiniteMint.burn(1);

        vm.stopPrank();

        // Hoax the sender and tx.origin
        startHoax(new_sender, new_sender, type(uint256).max);

        // Expect revert when trying to cancel a filled order
        // vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", new_sender, 0, 0));
        // ylo.cancelOrder(0);

        vm.stopPrank();
    }


    ////////////////////////////////////////////////////
    ///                 WITHDRAWALS                  ///
    ////////////////////////////////////////////////////

    function testWithdrawal() public {
        // Place and order
        address new_sender = address(1337);
        startHoax(new_sender, new_sender, type(uint256).max);
        ylo.placeOrder{value: 4}(address(infiniteMint), 1);

        // Make sure we incremented the order id
        assert(ylo.orderId() == 2);

        // Make sure our order is stored correctly
        (address o_o, address o_ta, uint256 o_p, uint256 o_q, uint256 o_n) = ylo.orderStore(1);
        assert(o_o == new_sender);
        assert(o_ta == address(infiniteMint));
        assert(o_p == 4);
        assert(o_q == 1);
        assert(o_n == 0);

        // Check our userOrder is correct
        (uint256 oi) = ylo.userOrders(new_sender, 0);
        assert(oi == 1);

        // Check the userOrderCount increased to 1
        (uint256 uoc) = ylo.userOrderCount(new_sender);
        assert(uoc == 1);
        vm.stopPrank();

        // Fill order in bot context
        startHoax(bot, bot, type(uint256).max / 2);

        // Mint the bot some NFTs
        infiniteMint.mint(bot, 1);
        assert(infiniteMint.ownerOf(1) == bot);

        // Approve the YobotERC721LimitOrder contract to transfer
        infiniteMint.approve(address(ylo), 1);
        assert(infiniteMint.getApproved(1) == address(ylo));
        ylo.fillOrder(1, 1, 4, bot, false); // don't send the payment now to test the balances
        
        // Check the bot and profit receiver balances
        (uint256 botBalance) = ylo.balances(bot);
        assert(botBalance == 2);
        (uint256 prBalance) = ylo.balances(profitReceiver);
        assert(prBalance == 2);
        vm.stopPrank();

        // Withdraw from the context of the profitReceiver
        startHoax(profitReceiver, profitReceiver, 100);
        assertEq(profitReceiver.balance, 100);
        ylo.withdraw();
        // Expect the profitReceiver to have a balance of ((botFeeBips * value) / 10_000)
        assertEq(profitReceiver.balance, 102);
        vm.stopPrank();

        // Withdraw the bot's profits later
        startHoax(bot, bot, 100);
        assertEq(bot.balance, 100);
        ylo.withdraw();
        // Expect the bot to have a balance of ((botFeeBips * value) / 10_000)
        assertEq(bot.balance, 102);
        vm.stopPrank();

        // Burn the minted erc721
        startHoax(new_sender, new_sender, type(uint256).max);
        infiniteMint.burn(1);
        vm.stopPrank();
    }

    ////////////////////////////////////////////////////
    ///                   HELPERS                    ///
    ////////////////////////////////////////////////////

    /// @notice Views a user's order
    /// @param _user the user who places an order
    /// @param _tokenAddress the token addres
    function testViewUserOrder(
        address _user,
        address _tokenAddress
    ) public {
        // Make sure our arguments are valid
        if(_user == address(0)) _user = address(1337);
        if (_tokenAddress == address(0)) _tokenAddress = address(15);
    
        // Expect Revert on a nonexistent order
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", _user, 0, 0));
        YobotERC721LimitOrder.Order memory preorder = ylo.viewUserOrder(_user, 0);
        assert(preorder.owner == address(0));
        assert(preorder.tokenAddress == address(0));
        assert(preorder.priceInWeiEach == 0);
        assert(preorder.quantity == 0);
        assert(preorder.num == 0);

        // Place the order
        startHoax(_user, _user, type(uint256).max);
        ylo.placeOrder{value: 10}(_tokenAddress, 10);
        vm.stopPrank();
        
        // The Order should be populated
        YobotERC721LimitOrder.Order memory placedorder = ylo.viewUserOrder(_user, 0);
        assert(placedorder.owner == _user);
        assert(placedorder.tokenAddress == _tokenAddress);
        assert(placedorder.priceInWeiEach == 1);
        assert(placedorder.quantity == 10);
        assert(placedorder.num == 0);

        // Cancel the Order
        startHoax(_user, _user, type(uint256).max);
        ylo.cancelOrder(0);
        vm.stopPrank();

        // Expect Revert on order that was deleted (the orderId == 0)
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", _user, 0, 0));
        YobotERC721LimitOrder.Order memory postorder = ylo.viewUserOrder(_user, 0);
        assert(postorder.owner == address(0));
        assert(postorder.tokenAddress == address(0));
        assert(postorder.priceInWeiEach == 0);
        assert(postorder.quantity == 0);
        assert(postorder.num == 0);
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
        // Make sure our arguments are valid
        if(_user == address(0)) _user = address(1337);
        if (_tokenAddress == address(0)) _tokenAddress = address(15);
    
        // Expect Revert on a nonexistent order
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", _user, 0, 0));
        YobotERC721LimitOrder.Order memory preorder = ylo.viewUserOrder(_user, 0);
        assert(preorder.owner == address(0));
        assert(preorder.tokenAddress == address(0));
        assert(preorder.priceInWeiEach == 0);
        assert(preorder.quantity == 0);
        assert(preorder.num == 0);

        // Place the order
        startHoax(_user, _user, type(uint256).max);
        ylo.placeOrder{value: 10}(_tokenAddress, 10);
        vm.stopPrank();
        
        // The Order should be populated
        YobotERC721LimitOrder.Order memory placedorder = ylo.viewUserOrder(_user, 0);
        assert(placedorder.owner == _user);
        assert(placedorder.tokenAddress == _tokenAddress);
        assert(placedorder.priceInWeiEach == 1);
        assert(placedorder.quantity == 10);
        assert(placedorder.num == 0);

        // Cancel the Order
        startHoax(_user, _user, type(uint256).max);
        ylo.cancelOrder(0);
        vm.stopPrank();

        // Expect Revert on order that was deleted (the orderId == 0)
        vm.expectRevert(abi.encodeWithSignature("OrderNonexistent(address,uint256,uint256)", _user, 0, 0));
        YobotERC721LimitOrder.Order memory postorder = ylo.viewUserOrder(_user, 0);
        assert(postorder.owner == address(0));
        assert(postorder.tokenAddress == address(0));
        assert(postorder.priceInWeiEach == 0);
        assert(postorder.quantity == 0);
        assert(postorder.num == 0);
    }
}
