// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Witness } from "src/Witness.sol";
import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public returns (Witness witness) {
        uint256 deployerKey = vm.envUint("DEPLOYMENT_PRIVATE_KEY");
        bytes32 salt = vm.envBytes32("DEPLOYMENT_SALT");
        address deployer = vm.addr(deployerKey);
        vm.broadcast();
        witness = new Witness{ salt: salt }(deployer);
    }
}
