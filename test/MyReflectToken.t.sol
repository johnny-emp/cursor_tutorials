// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MyReflectToken} from "../src/test/MyReflectToken.sol";

contract MyReflectTokenTest is Test {
    MyReflectToken private token;
    address private owner;
    address private user1;
    address private user2;
    address private taxAddress;

    uint256 private constant INITIAL_SUPPLY = 1_000_000e18;
    uint256 private constant BUY_TAX = 500; // 5%
    uint256 private constant SELL_TAX = 500; // 5%
    uint256 private constant PERCENT_TO_REFLECT = 5000; // 50%

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        taxAddress = makeAddr("taxAddress");

        token = new MyReflectToken(owner, INITIAL_SUPPLY, taxAddress, BUY_TAX, SELL_TAX, PERCENT_TO_REFLECT);
    }

    function testInitialSupply() public {
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function testBuyTax() public {
        uint256 amount = 1000e18;
        token.transfer(taxAddress, amount);

        uint256 expectedTaxBalance = amount * (token.TAX_DENOMINATOR() - SELL_TAX) / token.TAX_DENOMINATOR();

        assertEq(token.balanceOf(taxAddress), expectedTaxBalance);

        vm.prank(taxAddress);
        token.transfer(user1, expectedTaxBalance);

        uint256 expectedTax = (expectedTaxBalance * BUY_TAX) / token.TAX_DENOMINATOR();
        uint256 expectedAmount = expectedTaxBalance - expectedTax;

        assertEq(token.balanceOf(user1), expectedAmount);
    }

    function testSellTax() public {
        uint256 amount = 1000e18;
        token.transfer(user1, amount);

        vm.prank(user1);
        token.transfer(taxAddress, amount);

        uint256 expectedTax = (amount * SELL_TAX) / token.TAX_DENOMINATOR();
        uint256 expectedAmount = amount - expectedTax;

        assertEq(token.balanceOf(taxAddress), expectedAmount);
    }

    function testReflection() public {
        uint256 amount = 1000e18;
        token.transfer(user1, amount);
        token.transfer(user2, amount);

        uint256 initialBalance = token.balanceOf(user2);

        vm.prank(user1);
        token.transfer(taxAddress, amount);

        uint256 totalTax = (amount * SELL_TAX) / token.TAX_DENOMINATOR();
        uint256 reflectionAmount = (totalTax * PERCENT_TO_REFLECT) / token.TAX_DENOMINATOR();

        // User2's balance should increase due to reflection
        assertGt(token.balanceOf(user2), initialBalance);
        // The increase should be less than or equal to the reflection amount
        assertLe(token.balanceOf(user2) - initialBalance, reflectionAmount);
    }

    function testTreasuryFee() public {
        uint256 amount = 1000e18;
        token.transfer(user1, amount);

        uint256 initialTaxAddressBalance = token.balanceOf(taxAddress);
        assertEq(initialTaxAddressBalance, 0);

        vm.prank(user1);
        token.transfer(taxAddress, amount);

        uint256 totalTax = (amount * SELL_TAX) / token.TAX_DENOMINATOR();

        assertEq(token.balanceOf(taxAddress), amount - totalTax);
    }
}
