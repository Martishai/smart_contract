// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VestingWallet.sol";
import "../src/StudentToken.sol";

contract VestingWalletTest is Test {
    StudentToken token;
    VestingWallet vesting;
    address alice = address(1);

    function setUp() public {
        token = new StudentToken(1000 ether); // crée 1000 tokens pour le propriétaire
        vesting = new VestingWallet(address(token));
        token.approve(address(vesting), 100 ether); // approve le vesting pour 100 tokens
    }

    function testCreateVesting() public {
        vesting.createVestingSchedule(alice, 100 ether, 10, 100);
        (address ben,, , uint total, uint released) = vesting.vestingSchedules(alice);
        assertEq(ben, alice);
        assertEq(total, 100 ether);
        assertEq(released, 0);
    }

    function testCannotClaimBeforeCliff() public {
        vesting.createVestingSchedule(alice, 100 ether, 10, 100);
        vm.prank(alice);
        vm.expectRevert("No tokens to claim");
        vesting.claimVestedTokens();
    }

    function testClaimAfterCliff() public {
        vesting.createVestingSchedule(alice, 100 ether, 10, 100);
        vm.warp(block.timestamp + 50); // on avance le temps
        vm.prank(alice);
        vesting.claimVestedTokens();
        assertTrue(token.balanceOf(alice) > 0);
    }
}

