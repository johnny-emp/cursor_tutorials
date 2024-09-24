// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Reflect} from "./libraries/Reflect.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title AbstractReflectToken
 * @dev An abstract contract implementing reflection mechanism for ERC20 tokens
 */
abstract contract AbstractReflectToken is ERC20 {
    using Reflect for Reflect.TokenState;

    Reflect.TokenState private tokenState;

    uint256 public constant TAX_DENOMINATOR = 10_000;

    uint256 public buyTax;
    uint256 public sellTax;

    // The address that triggers the tax when tokens are bought from or sold to
    address public taxAddress;
    uint256 public percentToReflect;

    // Flag to prevent recursive fee handling
    bool private _handlingFee;

    /**
     * @dev Constructor to initialize the token with reflection mechanism
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param buyTax_ The tax rate for buying tokens (in basis points)
     * @param sellTax_ The tax rate for selling tokens (in basis points)
     * @param taxAddress_ The address that triggers tax events
     * @param percentToReflect_ The percentage of tax to be reflected (in basis points)
     */
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

    // View Functions

    /**
     * @dev Returns the balance of the specified account
     * @param account The address to query the balance of
     * @return The balance of the specified account
     */
    function balanceOf(address account) public view override returns (uint256) {
        return tokenState.userBalance(account);
    }

    /**
     * @dev Returns the total supply of the token
     * @return The total supply of the token
     */
    function totalSupply() public view override returns (uint256) {
        return tokenState.totalTokens;
    }

    // Internal Functions

    /**
     * @dev Internal function to handle token transfers and apply reflection mechanism
     * @param from The address tokens are transferred from
     * @param to The address tokens are transferred to
     * @param value The amount of tokens transferred
     */
    function _update(address from, address to, uint256 value) internal override {
        if (from == address(0)) {
            // Minting new tokens
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

    /**
     * @dev Internal function to handle the reflection mechanism
     * @param feeAmount The amount of fee to be reflected
     */
    function _handleReflection(uint256 feeAmount) internal {
        if (feeAmount == 0) {
            return;
        }
        _handlingFee = true;

        uint256 reflectionFeeAmount = (feeAmount * percentToReflect) / TAX_DENOMINATOR;
        uint256 treasuryFeeAmount = feeAmount - reflectionFeeAmount;

        tokenState.increaseUserBalance(address(this), treasuryFeeAmount);
        _handleTreasuryFee(treasuryFeeAmount);
        if (reflectionFeeAmount > 0) {
            _handleReflectionFee(reflectionFeeAmount);
        }

        _handlingFee = false;
    }

    /**
     * @dev Internal function to handle the reflection fee
     * @param reflectionFeeAmount The amount of fee to be reflected
     */
    function _handleReflectionFee(uint256 reflectionFeeAmount) internal virtual {
        tokenState.increaseFragmentsPerToken(reflectionFeeAmount);
    }

    /**
     * @dev Internal function to handle the treasury fee
     * @param treasuryFeeAmount The amount of fee to be sent to the treasury
     */
    function _handleTreasuryFee(uint256 treasuryFeeAmount) internal virtual;
}
