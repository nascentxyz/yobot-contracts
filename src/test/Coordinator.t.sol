// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Coordinator} from "../Coordinator.sol";

contract CoordinatorTest is DSTestPlus {
    Coordinator public coord;

    /// @dev internal contract state
    address public coordinator;
    address public profitReceiver = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B; // VB, a burn address (:
    uint32 public botFeeBips = 5_000; // 50% 

    function setUp() public {
        coord = new Coordinator(profitReceiver, botFeeBips);

        // Sanity check on the coordinator
        coordinator = coord.coordinator();
        assert(coordinator == address(this));
    }

    ////////////////////////////////////////////////////
    ///                  COORDINATOR                 ///
    ////////////////////////////////////////////////////

    /// @dev property base the changeCoordinator function
    /// @param newCoordinator the new coordinator set with changeCoordinator
    function testChangeCoordinator(address newCoordinator) public {
        // we need to use a fresh coord since this test is run multiple times, causing coordinator caching
        Coordinator tempcoord = new Coordinator(profitReceiver, botFeeBips);
        assert(tempcoord.coordinator() == address(this));
        tempcoord.changeCoordinator(newCoordinator);
        assert(tempcoord.coordinator() == newCoordinator);
    }

    /// @dev Ensures the onlyCoordinator modifier is working for changeCoordinator
    /// @param honestCoordinator the honest coordinator of a Coordinator contract
    /// @param newCoordinator a new coordinator attempted to be set by address(this)
    function testFailChangeCoordinator(
        address honestCoordinator,
        address newCoordinator
    ) public {
        // if this is the honestCoordinator, changing the coordinator to the `newCoordinator` won't fail
        assert(address(this) != honestCoordinator);

        // create a new coord with the honest coordinator
        Coordinator tempcoord = new Coordinator(profitReceiver, botFeeBips);
        tempcoord.changeCoordinator(honestCoordinator);
        assert(tempcoord.coordinator() == honestCoordinator);

        // this should fail since the onlyCoordinator modifier exists
        tempcoord.changeCoordinator(newCoordinator);
    }

    ////////////////////////////////////////////////////
    ///                PROFIT RECEIVER               ///
    ////////////////////////////////////////////////////

    /// @dev property base the changeProfitReceiver function
    function testChangeProfitReceiver(address newProfitReceiver) public {
        // we need to use a fresh coord since this test is run multiple times,
        // causing coordinator caching
        Coordinator tempcoord = new Coordinator(profitReceiver, botFeeBips);
        assert(tempcoord.profitReceiver() == profitReceiver);
        tempcoord.changeProfitReceiver(newProfitReceiver);
        assert(tempcoord.profitReceiver() == newProfitReceiver);
    }

    /// @dev Ensures the onlyCoordinator modifier is working for changeProfitReceiver
    /// @param honestCoordinator the honest coordinator of a Coordinator contract
    /// @param newProfitReceiver a new profit receiver attempted to be set by address(this)
    function testFailChangeProfitReceiver(
        address honestCoordinator,
        address newProfitReceiver
    ) public {
        // if this is the honestCoordinator, changing the coordinator to the `newProfitReceiver` won't fail
        assert(address(this) != honestCoordinator);

        // create a new coord with the honest coordinator
        Coordinator tempcoord = new Coordinator(profitReceiver, botFeeBips);
        tempcoord.changeCoordinator(honestCoordinator);
        assert(tempcoord.coordinator() == honestCoordinator);

        // this should fail since the onlyCoordinator modifier exists
        tempcoord.changeProfitReceiver(newProfitReceiver);
    }

    ////////////////////////////////////////////////////
    ///                  BROKER FEE                  ///
    ////////////////////////////////////////////////////

    /// @dev "property base" test the changeBotFeeBips function
    /// @param oldFee the old botFeeBips specified in the constructor
    /// @param newFee the new botFeeBips set with changeBotFeeBips
    function testChangeBotFeeBips(uint32 oldFee, uint32 newFee) public {
        uint32 adjustedOldFee = oldFee % (coord.MAXIMUM_FEE() + 1);
        uint32 adjustedNewFee = newFee % (coord.MAXIMUM_FEE() + 1);
        Coordinator tempcoord = new Coordinator(address(0), adjustedOldFee);
        tempcoord.changeBotFeeBips(adjustedNewFee);
        assert(tempcoord.botFeeBips() == adjustedNewFee);
    }

    /// @dev Ensures the onlyCoordinator modifier is working for changeBotFeeBips
    /// @param honestCoordinator the honest coordinator of a Coordinator contract
    /// @param newFee the new botFeeBips
    function testFailChangeBotFeeBipsImposter(address honestCoordinator, uint32 newFee)
        public
    {
        // if this is the honestCoordinator, changing the coordinator to the `newFee` won't fail
        assert(address(this) != honestCoordinator);

        // Adjust the fee to make sure the fee isn't causing the revert
        uint32 adjustedFee = newFee % (coord.MAXIMUM_FEE() + 1);

        // create a new coord with the honest coordinator
        Coordinator tempcoord = new Coordinator(profitReceiver, botFeeBips);
        tempcoord.changeCoordinator(honestCoordinator);
        assert(tempcoord.coordinator() == honestCoordinator);

        // this should fail since the onlyCoordinator modifier exists
        tempcoord.changeBotFeeBips(adjustedFee);
    }

    /// @dev Ensures that the fee change fails for excessive fees
    /// @param newFee the new botFeeBips
    function testFailChangeBotFeeBipsExcessive(uint32 newFee)
        public
    {
        // Make sure the fee > MAXIMUM_FEE()
        uint32 adjustedFee = newFee;
        if (adjustedFee < coord.MAXIMUM_FEE()) adjustedFee += coord.MAXIMUM_FEE() - adjustedFee + 1;

        // this should fail since the fee will be > coord.MAXIMUM_FEE()
        coord.changeBotFeeBips(adjustedFee);
    }
}
