// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { Witness } from "src/Witness.sol";
import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (Witness witness) {
        uint256 deployerPrivateKey = vm.envUint("ETH_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        witness = new Witness(vm.addr(deployerPrivateKey));
        vm.stopBroadcast();
    }
}
