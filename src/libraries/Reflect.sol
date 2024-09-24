// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Reflect {
    struct TokenState {
        uint256 fragmentsPerToken;
        uint256 totalTokens;
        mapping(address => uint256) userFragments;
    }

    function increaseFragmentsPerToken(TokenState storage self, uint256 amount) internal {
        require(amount > 0, "Amount must be greater than zero");
        
        self.fragmentsPerToken = (self.fragmentsPerToken * self.totalTokens) / (self.totalTokens + amount);
    }

    function fragmentsToTokens(TokenState storage self, uint256 fragments) internal view returns (uint256) {
        require(self.fragmentsPerToken > 0, "Fragments per token must be set");
        return fragments / self.fragmentsPerToken;
    }

    function tokensToFragments(TokenState storage self, uint256 tokens) internal view returns (uint256) {
        return tokens * self.fragmentsPerToken;
    }

    function userBalance(TokenState storage self, address user) internal view returns (uint256) {
        return self.userFragments[user] / self.fragmentsPerToken;
    }
    
    function increaseUserBalance(TokenState storage self, address user, uint256 amount) internal {
        self.userFragments[user] += tokensToFragments(self, amount);
    }

    function decreaseUserBalance(TokenState storage self, address user, uint256 amount) internal {
        self.userFragments[user] -= tokensToFragments(self, amount);
    }
}