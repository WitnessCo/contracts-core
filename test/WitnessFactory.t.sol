// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.18;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { StdCheatsSafe } from "forge-std/src/StdCheats.sol";

import { IWitnessFactory } from "src/interfaces/IWitnessFactory.sol";
import { MockWitnessCore } from "test/MockWitnessCore.sol";
import { WitnessFactory } from "src/WitnessFactory.sol";

contract WitnessFactoryTest is PRBTest, StdUtils, StdCheatsSafe {
    MockWitnessCore public core;
    WitnessFactory public factory;
    address public admin;
    address public owner;
    address public instance;
    uint96 public instanceId;
    uint256 public size;
    bytes32[] public range;

    function setUp() public {
        admin = makeAddr("admin");
        owner = makeAddr("owner");
        core = new MockWitnessCore();
        factory = new WitnessFactory(admin, address(core));
        size = 1;
        range = new bytes32[](1);
        range[0] = bytes32(uint256(1));
    }
    
    function testCreateWitness() public {
        vm.prank(owner);
        instance = factory.createWitness(owner, size, range);
        ++instanceId;
        assertEq(factory.instances(instanceId), instance);
        assertEq(factory.instanceId(), instanceId);
        assertEq(MockWitnessCore(instance).owner(), owner);
    }

    function testCreateWitnessRevertsWhenInvalidOwnerZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(IWitnessFactory.InvalidOwnerZeroAddress.selector);
        factory.createWitness(address(0), size, range);
    }

    function testSetImplementation() public {
        vm.prank(admin);
        factory.setImplementation(address(core));
        assertEq(factory.implementation(), address(core));
    }

    function testGetDeterministicAddress() public {
        address deterministic = factory.getDeterministicAddress(owner);
        testCreateWitness();
        assertEq(instance, deterministic);
    }
}