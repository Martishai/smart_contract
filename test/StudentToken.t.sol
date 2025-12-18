// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StudentToken.sol";

contract StudentTokenTest is Test {

    StudentToken token;

    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);

    function setUp() public {
        token = new StudentToken(1000 ether);

        // Distribution initiale
        token.transfer(alice, 300 ether);
        token.transfer(bob, 200 ether);
    }

    function testInitialBalances() public {
        assertEq(token.balanceOf(address(this)), 500 ether);
        assertEq(token.balanceOf(alice), 300 ether);
        assertEq(token.balanceOf(bob), 200 ether);
    }

    function testTransfer() public {
        vm.prank(alice);
        token.transfer(charlie, 100 ether);

        assertEq(token.balanceOf(alice), 200 ether);
        assertEq(token.balanceOf(charlie), 100 ether);
    }

    function testTransferFailsIfInsufficientBalance() public {
        vm.prank(charlie);
        vm.expectRevert("Insufficient balance");
        token.transfer(alice, 10 ether);
    }

    function testApproveAndTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 50 ether);

        vm.prank(bob);
        token.transferFrom(alice, charlie, 50 ether);

        assertEq(token.balanceOf(alice), 250 ether);
        assertEq(token.balanceOf(charlie), 50 ether);
    }

    function testMint() public {
        token.mint(alice, 200 ether);

        assertEq(token.balanceOf(alice), 500 ether);
        assertEq(token.totalSupply(), 1200 ether);
    }

    function testBurn() public {
        vm.prank(alice);
        token.burn(100 ether);

        assertEq(token.balanceOf(alice), 200 ether);
        assertEq(token.totalSupply(), 900 ether);
    }

    function testBlockAccount() public {
        token.blockAccount(alice);

        vm.prank(alice);
        vm.expectRevert("Account blocked");
        token.transfer(bob, 10 ether);
    }

    function testUnblockAccount() public {
        token.blockAccount(alice);
        token.unblockAccount(alice);

        vm.prank(alice);
        token.transfer(bob, 10 ether);

        assertEq(token.balanceOf(bob), 210 ether);
    }

    function testBlockedCannotReceive() public {
        token.blockAccount(bob);

        vm.prank(alice);
        vm.expectRevert("Account blocked");
        token.transfer(bob, 10 ether);
    }

    function testAllowanceDecreases() public {
        vm.prank(alice);
        token.approve(bob, 100 ether);

        vm.prank(bob);
        token.transferFrom(alice, charlie, 40 ether);

        assertEq(token.allowance(alice, bob), 60 ether);
    }
}

