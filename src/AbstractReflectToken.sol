// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Reflect} from "./libraries/Reflect.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract AbstractReflectToken is ERC20 {
    using Reflect for Reflect.TokenState;

    Reflect.TokenState private tokenState;

    uint256 public constant TAX_DENOMINATOR = 10_000;

    uint256 public buyTax;
    uint256 public sellTax;

    // the address that is targeted to trigger the tax
    address public taxAddress;
    uint256 public percentToReflect;

    bool private _handlingFee;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 buyTax_,
        uint256 sellTax_,
        address taxAddress_,
        uint256 percentToReflect_
    ) ERC20(name_, symbol_) {
        tokenState.fragmentsPerToken = 1e32;

        buyTax = buyTax_;
        sellTax = sellTax_;
        taxAddress = taxAddress_;
        percentToReflect = percentToReflect_;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from == address(0)) {
            // when minting tokens, we need to update the total supply
            tokenState.totalTokens += value;
        } else {
            tokenState.decreaseUserBalance(from, value);
        }

        uint256 feeAmount;
        if (!_handlingFee) {
            if (from == taxAddress) {
                feeAmount = (value * buyTax) / TAX_DENOMINATOR;
            } else if (to == taxAddress) {
                feeAmount = (value * sellTax) / TAX_DENOMINATOR;
            }

            if (feeAmount > 0) {
                _handleReflection(feeAmount);
            }
        }

        tokenState.increaseUserBalance(to, value - feeAmount);

        emit Transfer(from, to, value - feeAmount);
    }

    function _handleReflection(uint256 feeAmount) internal {
        if (feeAmount == 0) {
            return;
        }
        _handlingFee = true;

        tokenState.increaseUserBalance(address(this), feeAmount / 2);

        uint256 reflectionFeeAmount = (feeAmount * percentToReflect) / TAX_DENOMINATOR;
        uint256 treasuryFeeAmount = feeAmount - reflectionFeeAmount;

        _handleTreasuryFee(treasuryFeeAmount);
        if (reflectionFeeAmount > 0) {
            _handleReflectionFee(reflectionFeeAmount);
        }

        _handlingFee = false;
    }

    function _handleTreasuryFee(uint256 treasuryFeeAmount) internal virtual;

    function _handleReflectionFee(uint256 reflectionFeeAmount) internal virtual {
        tokenState.increaseFragmentsPerToken(reflectionFeeAmount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenState.userBalance(account);
    }

    function totalSupply() public view override returns (uint256) {
        return tokenState.totalTokens;
    }
}
