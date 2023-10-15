//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public OWNER = makeAddr("owner");


    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
    }

    function testProxyStartsAsBoxV1() public{
        address proxyAddress = deployer.deployBox();
        vm.expectRevert();
        BoxV2(proxyAddress).setNumber(7);
    }

    function testUpgrades() public {
        address proxyAddress = deployer.deployBox();

        BoxV2 box2 = new BoxV2();

        vm.prank(BoxV1(proxyAddress).owner());
        BoxV1(proxyAddress).transferOwnership(msg.sender);

        address proxy = upgrader.upgradeBox(proxyAddress, address(box2));

        uint256 expectedVersion = 2;
        assertEq(expectedVersion, BoxV2(proxy).version());

        BoxV2(proxy).setNumber(7);
        assertEq(7, BoxV2(proxy).getNumber());
    }
}