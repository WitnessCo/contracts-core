// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";

import { Deploy, Witness } from "script/Deploy.s.sol";

// NOTE: `DEPLOYMENT_SALT` is derived using `Witness` contract initcode hash.
//       keccak256(abi.encodePacked(type(c).creationCode, abi.encode(params)))
address constant EXPECTED_ADDR = address(0x0000000825d7f68ACb550D9B8392BF328C3C6e24);

/// @dev Modifying `Witness` contract will cause this to fail.
//       Recalculate initcode hash and deployment salt to fix.
contract DeployTest is PRBTest, StdUtils {
    function testRunCorrectness() 
        public 
    {
        uint256 deployerKey = vm.envUint("DEPLOYMENT_PRIVATE_KEY");
        Witness c = new Deploy().run();
        assertEq(address(c), EXPECTED_ADDR);
        assertEq(c.owner(), vm.addr(deployerKey));
    }
}