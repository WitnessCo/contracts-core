// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";

import { Deploy, Witness } from "script/Deploy.s.sol";

// NOTE: `DEPLOYMENT_SALT` is derived using `Witness` contract initcode hash.
//       keccak256(abi.encodePacked(type(c).creationCode, abi.encode(params)))
address constant EXPECTED_ADDR = address(0x0000000E89DBAFBDDe5a59ABd49be9fdEbe76eE2);

/// @dev Modifying `Witness` contract will cause this to fail.
//       Recalculate initcode hash and deployment salt to fix.
contract DeployTest is PRBTest, StdUtils {
    event log(bytes32);

    function testRunCorrectness() 
        public 
    {
        uint256 deployerKey = vm.envUint("DEPLOYMENT_PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        emit log(keccak256(abi.encodePacked(type(Witness).creationCode, abi.encode(deployer))));
        Witness c = new Deploy().run();
        assertEq(address(c), EXPECTED_ADDR);
        assertEq(c.owner(), deployer);
    }
}