// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/* solhint-disable max-line-length */

import {Coordinator} from "./Coordinator.sol";
import {IArtBlocksFactory} from "./external/IArtBlocksFactory.sol";

/// @title YobotBroker
/// @author Andreas Bigger <andreas@nascent.xyz> et al
/// @notice An abstract Yobot broker enabling permissionless markets between flashbot
/// 				searchers and users minting fixed-price drops.
abstract contract YobotBroker is Coordinator {
    // TODO: can we coalesce artblocks project ids into token addresses for general erc 721 brokering

    // OpenZeppelin's sendValue function, used for transfering ETH out of this contract
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}