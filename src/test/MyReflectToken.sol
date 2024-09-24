// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AbstractReflectToken} from "../AbstractReflectToken.sol";

contract MyReflectToken is AbstractReflectToken {
    constructor(
        address owner,
        uint256 initialSupply,
        address taxAddress,
        uint256 buyTax,
        uint256 sellTax,
        uint256 percentToReflect
    ) AbstractReflectToken("My Reflect Token", "MRT", buyTax, sellTax, taxAddress, percentToReflect) {
        _mint(owner, initialSupply);
    }

    function _handleTreasuryFee(uint256 amount) internal override {
        _transfer(address(this), address(0xdead), amount);
    }
}
