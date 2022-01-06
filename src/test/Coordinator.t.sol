// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Coordinator} from "../Coordinator.sol";

contract CoordinatorTest is DSTestPlus {
    Coordinator public yabb;

    /// @dev internal contract state
    address public coordinator;
    address public profitReceiver;
    uint256 public botFeeBips;

    function setUp(address _profitReceiver, uint256 _botFeeBips) public {
        profitReceiver = _profitReceiver;
        botFeeBips = _botFeeBips;
        yabb = new Coordinator(profitReceiver, botFeeBips);

        // Sanity check on the coordinator
        assert(yabb.coordinator() == address(this));
        coordinator = yabb.coordinator();
    }

    /*///////////////////////////////////////////////////////////////
                        COORDINATOR
    //////////////////////////////////////////////////////////////*/

    /// @dev property base the changeCoordinator function
    /// @param newCoordinator the new coordinator set with changeCoordinator
    function testChangeCoordinator(address newCoordinator) public {
        // we need to use a fresh yabb since this test is run multiple times, causing coordinator caching
        Coordinator tempyabb = new Coordinator(profitReceiver, botFeeBips);
        tempyabb.changeCoordinator(newCoordinator);
        assert(tempyabb.coordinator() == newCoordinator);
    }

    /// @dev Ensures the onlyCoordinator modifier is working for changeCoordinator
    /// @param honestCoordinator the honest coordinator of a Coordinator contract
    /// @param newCoordinator a new coordinator attempted to be set by address(this)
    function testFailChangeCoordinator(address honestCoordinator, address newCoordinator) public {
        // if this is the honestCoordinator, changing the coordinator to the `newCoordinator` won't fail
        assert(address(this) != honestCoordinator);

        // create a new yabb with the honest coordinator
        Coordinator tempyabb = new Coordinator(profitReceiver, botFeeBips);
        tempyabb.changeCoordinator(honestCoordinator);
        assert(tempyabb.coordinator() == honestCoordinator);

        // this should fail since the onlyCoordinator modifier exists
        tempyabb.changeCoordinator(newCoordinator);
    }

    /*///////////////////////////////////////////////////////////////
                        PROFIT RECEIVER
    //////////////////////////////////////////////////////////////*/

    /// @dev property base the changeProfitReceiver function
    function testChangeProfitReceiver(address newProfitReceiver) public {
        // we need to use a fresh yabb since this test is run multiple times, causing coordinator caching
        Coordinator tempyabb = new Coordinator(profitReceiver, botFeeBips);
        tempyabb.changeProfitReceiver(newProfitReceiver);
        assert(tempyabb.profitReceiver() == newProfitReceiver);
    }

    /// @dev Ensures the onlyCoordinator modifier is working for changeProfitReceiver
    /// @param honestCoordinator the honest coordinator of a Coordinator contract
    /// @param newProfitReceiver a new profit receiver attempted to be set by address(this)
    function testFailChangeProfitReceiver(address honestCoordinator, address newProfitReceiver) public {
        // if this is the honestCoordinator, changing the coordinator to the `newProfitReceiver` won't fail
        assert(address(this) != honestCoordinator);

        // create a new yabb with the honest coordinator
        Coordinator tempyabb = new Coordinator(profitReceiver, botFeeBips);
        tempyabb.changeCoordinator(honestCoordinator);
        assert(tempyabb.coordinator() == honestCoordinator);

        // this should fail since the onlyCoordinator modifier exists
        tempyabb.changeProfitReceiver(newProfitReceiver);
    }

    /*///////////////////////////////////////////////////////////////
                        ART BLOCKS BROKER FEE BIPS
    //////////////////////////////////////////////////////////////*/

    /// @notice the new fee must always be less than the old fee
    /// @dev property base the changeBotFeeBips function
    /// @param oldFee the old botFeeBips specified in the constructor
    /// @param newFee the new botFeeBips set with changeBotFeeBips
    function testChangeBotFeeBips(uint256 oldFee, uint256 newFee) public {
        if (newFee < oldFee && oldFee < 500) {
            Coordinator tempyabb = new Coordinator(address(0), oldFee);
            tempyabb.changeBotFeeBips(newFee);
            assert(tempyabb.botFeeBips() == newFee);
        } else if (newFee > oldFee && newFee < 500) {
            // in this case, newFee acts as the old fee and vise versa...
            Coordinator tempyabb = new Coordinator(address(0), newFee);
            tempyabb.changeBotFeeBips(oldFee);
            assert(tempyabb.botFeeBips() == oldFee);
        } else {
            // Either the fees are equal, or one of the fees is greater than 10,000
            assert(oldFee == newFee || (oldFee > 500 || newFee > 500));
        }
    }

    /// @dev Ensures the onlyCoordinator modifier is working for changeBotFeeBips
    /// @param honestCoordinator the honest coordinator of a Coordinator contract
    /// @param newFee the new botFeeBips attempted
    ///               to be set with changeBotFeeBips and address(this)
    function testFailchangeBotFeeBips(address honestCoordinator, uint256 newFee) public {
        // if this is the honestCoordinator, changing the coordinator to the `newFee` won't fail
        assert(address(this) != honestCoordinator);

        // the new botFeeBips must be less than the previous fee
        assert(newFee < botFeeBips);

        // create a new yabb with the honest coordinator
        Coordinator tempyabb = new Coordinator(profitReceiver, botFeeBips);
        tempyabb.changeCoordinator(honestCoordinator);
        assert(tempyabb.coordinator() == honestCoordinator);

        // this should fail since the onlyCoordinator modifier exists
        tempyabb.changeBotFeeBips(newFee);
    }
}