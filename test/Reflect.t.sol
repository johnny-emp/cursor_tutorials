// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/libraries/Reflect.sol";

contract ReflectTest is Test {
    using Reflect for Reflect.TokenState;

    Reflect.TokenState private tokenState;
    Reflect.TokenState private emptyState;
    address private user1 = address(1);
    address private user2 = address(2);

    function setUp() public {
        tokenState.fragmentsPerToken = 1e32; // 1 token = 1e32 fragments initially
        tokenState.totalTokens = 1000000; // 1 million tokens total supply
    }

    function testFragmentsIncreasePerUser() public {
        tokenState.totalTokens = 1_000_000e18;
        uint256 totalFragments = tokenState.tokensToFragments(tokenState.totalTokens);

        uint256 supplyIncrease = 100e18;
        tokenState.increaseFragmentsPerToken(supplyIncrease);
        assertEq(
            tokenState.fragmentsToTokens(totalFragments),
            1_000_000e18 + supplyIncrease,
            "Total fragments should remain the same"
        );
    }

    function testIncreaseFragmentsPerToken() public {
        uint256 initialFragmentsPerToken = tokenState.fragmentsPerToken;
        tokenState.increaseFragmentsPerToken(100_000e18); // Increase by 100,000 tokens
        assertLt(tokenState.fragmentsPerToken, initialFragmentsPerToken, "Fragments per token should increase");
    }

    function testFragmentsToTokens() public view {
        uint256 fragments = 5e32; // 5 tokens worth of fragments
        uint256 tokens = tokenState.fragmentsToTokens(fragments);
        assertEq(tokens, 5, "5e18 fragments should equal 5 tokens");
    }

    function testTokensToFragments() public view {
        uint256 tokens = 10;
        uint256 fragments = tokenState.tokensToFragments(tokens);
        assertEq(fragments, 10e32, "10 tokens should equal 10e18 fragments");
    }

    function testUserBalance() public {
        tokenState.increaseUserBalance(user1, 100);
        uint256 balance = tokenState.userBalance(user1);
        assertEq(balance, 100, "User balance should be 100 tokens");
    }

    function testIncreaseAndDecreaseUserBalance() public {
        tokenState.increaseUserBalance(user2, 500);
        assertEq(tokenState.userBalance(user2), 500, "User balance should be 500 tokens after increase");

        tokenState.decreaseUserBalance(user2, 200);
        assertEq(tokenState.userBalance(user2), 300, "User balance should be 300 tokens after decrease");
    }

    function testRevertOnZeroAmount() public {
        vm.expectRevert("Amount must be greater than zero");
        tokenState.increaseFragmentsPerToken(0);
    }

    function testRevertOnZeroFragmentsPerToken() public {
        vm.expectRevert("Fragments per token must be set");
        emptyState.fragmentsToTokens(1e18);
    }
}
