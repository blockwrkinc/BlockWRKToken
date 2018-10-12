pragma solidity ^0.4.24;

import "./BlockWRKToken.sol";

/**
 * @title BlockWRKICO
 * @notice This contract manages the sale of WRK tokens for the BlockWRK ICO.
 * @dev This contract incorporates elements of OpenZeppelin crowdsale contracts with some modifications.
 * @author jsdavis28
 */
 contract BlockWRKICO is BlockWRKToken {
    /**
     * @dev Sets public variables for BlockWRK ICO
     */
    address public salesWallet;
    uint256 public cap;
    uint256 public closingTime;
    uint256 public currentTierRate;
    uint256 public openingTime;
    uint256 public weiRaised;

    /**
     * @dev Sets private variables for custom token functions.
     */
    uint256 internal availableInCurrentTier;
    uint256 internal availableInSale;
    uint256 internal tier1Rate = 200000;
    uint256 internal tier2Rate = 40000;
    uint256 internal tier3Rate = 20000;
    uint256 internal tier4Rate = 10000;
    uint256 internal tier5Rate = 10000;
    uint256 internal tier6Rate = 10000;
    uint256 internal tier7Rate = 10000;
    uint256 internal tier8Rate = 10000;
    uint256 internal tier9Rate = 10000;
    uint256 internal tier10Rate = 10000;
    uint256 internal tier1Volume = decimalValue.mul(100000000);
    uint256 internal tier2Volume = decimalValue.mul(200000000);
    uint256 internal tier3Volume = decimalValue.mul(500000000);
    uint256 internal tier4Volume = decimalValue.mul(500000000);
    uint256 internal tier5Volume = decimalValue.mul(500000000);
    uint256 internal tier6Volume = decimalValue.mul(500000000);
    uint256 internal tier7Volume = decimalValue.mul(500000000);
    uint256 internal tier8Volume = decimalValue.mul(500000000);
    uint256 internal tier9Volume = decimalValue.mul(500000000);
    uint256 internal tier10Volume = decimalValue.mul(500000000);
    uint256 internal totalSaleVolume = decimalValue.mul(4300000000);
    uint256 internal totalTokenVolume = decimalValue.mul(11900000000);

    constructor() public {
        cap = 20000000000000000000000000000000000000000;
        //salesWallet =
        openingTime = now;
        closingTime = now;
    }

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * Event marking the transfer of any remaining WRK to the distribution pool post-ICO
     * @param wallet The address remaining sale tokens are delivered
     * @param amount The remaining tokens after the sale has closed
     */
     event CloseoutSale(address indexed wallet, uint256 amount);



    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
     * @dev fallback function
     */
    function () external payable {
      buyTokens(msg.sender);
    }

    /**
     * @dev Allows ICO participants to purchase WRK tokens
     * @param _beneficiary The address of the ICO participant
     */
    function buyTokens(address _beneficiary) public payable {
      uint256 weiAmount = msg.value;
      _preValidatePurchase(_beneficiary, weiAmount);

      //Calculate number of tokens to issue
      uint256 tokens = _calculateTokens(weiAmount);

      //Calculate new amount of Wei raised
      weiRaised = weiRaised.add(weiAmount);

      //Process token purchase and forward funcds to salesWallet
      _processPurchase(_beneficiary, tokens);
      _forwardFunds();
      emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public view returns (bool) {
      return weiRaised >= cap;
    }

     /**
      * @dev Checks whether the period in which the crowdsale is open has already elapsed.
      * @return Whether crowdsale period has elapsed
      */
     function hasClosed() public view returns (bool) {
         // solium-disable-next-line security/no-block-members
         return block.timestamp > closingTime;
     }



    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------

    /**
     * @dev Calculates total number of tokens to sell, accounting for varied rates per tier.
     * @param _amountWei Total amount of Wei sent by ICO participant
     * @return Total number of tokens to send to buyer
     */
    function _calculateTokens(uint256 _amountWei) internal returns (uint256) {
        //Tokens pending in sale
        uint256 tokenAmountPending;

        //Tokens to be sold
        uint256 tokenAmountToIssue;

        //Note: tierCaps must take into account reserved and distribution pool tokens
        //Determine tokens remaining in tier and set current token rate
        uint256 tokensRemainingInTier = _getRemainingTokens(totalSupply_);

        //Calculate new tokens pending sale
        uint256 newTokens = _getTokenAmount(_amountWei);

        //Check if _newTokens exceeds _tokensRemainingInTier
        bool nextTier = true;
        while (nextTier) {
            if (newTokens > tokensRemainingInTier) {
                //Get tokens sold in current tier and add to pending total supply
                tokenAmountPending = tokensRemainingInTier;
                uint256 newTotal = totalSupply_.add(tokenAmountPending);

                //Save number of tokens pending from current tier
                tokenAmountToIssue = tokenAmountToIssue.add(tokenAmountPending);

                //Calculate Wei spent in current tier and set remaining Wei for next tier
                uint256 pendingAmountWei = tokenAmountPending.div(currentTierRate);
                uint256 remainingWei = _amountWei.sub(pendingAmountWei);

                //Calculate number of tokens in next tier
                tokensRemainingInTier = _getRemainingTokens(newTotal);
                newTokens = _getTokenAmount(remainingWei);
            } else {
                tokenAmountToIssue = tokenAmountToIssue.add(newTokens);
                nextTier = false;
                _setAvailableInCurrentTier(tokensRemainingInTier, newTokens);
                _setAvailableInSale(newTokens);
            }
        }

        //Return amount of tokens to be issued in this sale
        return tokenAmountToIssue;
    }

    /**
     * @dev Source of tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        totalSupply_ = totalSupply_.add(_tokenAmount);
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        salesWallet.transfer(msg.value);
    }

    /**
     * @dev Performs a binary search of the sale tiers to determine current sales volume and rate.
     * @param _tokensSold The total number of tokens sold in the ICO prior to this tx
     * @return The remaining number of tokens for sale in the current sale tier
     */
    function _getRemainingTokens(uint256 _tokensSold) internal returns (uint256) {
        //Deteremine the current sale tier, set current rate and find remaining tokens in tier
        uint256 remaining;
        if (_tokensSold < tier5Volume) {
            if (_tokensSold < tier3Volume) {
                if (_tokensSold < tier1Volume) {
                    _setCurrentTierRate(tier1Rate);
                    remaining = tier1Volume.sub(_tokensSold);
                } else if (_tokensSold < tier2Volume) {
                    _setCurrentTierRate(tier2Rate);
                    remaining = tier2Volume.sub(_tokensSold);
                } else {
                    _setCurrentTierRate(tier3Rate);
                    remaining = tier3Volume.sub(_tokensSold);
                }
            } else {
                if (_tokensSold < tier4Volume) {
                    _setCurrentTierRate(tier4Rate);
                    remaining = tier4Volume.sub(_tokensSold);
                } else {
                    _setCurrentTierRate(tier5Rate);
                    remaining = tier5Volume.sub(_tokensSold);
                }
            }
        } else {
            if (_tokensSold < tier8Volume) {
                if (_tokensSold < tier6Volume) {
                    _setCurrentTierRate(tier6Rate);
                    remaining = tier6Volume.sub(_tokensSold);
                } else if (_tokensSold < tier7Volume) {
                    _setCurrentTierRate(tier7Rate);
                    remaining = tier7Volume.sub(_tokensSold);
                } else {
                    _setCurrentTierRate(tier8Rate);
                    remaining = tier8Volume.sub(_tokensSold);
                }
            } else {
                if (_tokensSold < tier9Volume) {
                    _setCurrentTierRate(tier9Rate);
                    remaining = tier9Volume.sub(_tokensSold);
                } else {
                    _setCurrentTierRate(tier10Rate);
                    remaining = tier10Volume.sub(_tokensSold);
                }
            }
        }

        return remaining;
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(currentTierRate).mul(decimalValue).div(1 ether);
    }

    /**
     * @dev Validation of an incoming purchase.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
        require(weiRaised.add(_weiAmount) <= cap);
        // solium-disable-next-line security/no-block-members
        require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function _setAvailableInCurrentTier(uint256 _tierPreviousRemaining, uint256 _newIssue) internal {
        availableInCurrentTier = _tierPreviousRemaining.sub(_newIssue);
    }

    function _setAvailableInSale(uint256 _newIssue) internal {
        availableInSale = totalSaleVolume.sub(_newIssue);
    }

    function _setCurrentTierRate(uint256 _rate) internal {
        currentTierRate = _rate;
    }

    function tokensRemainingInSale() public view returns (uint256) {
        return availableInSale;
    }

    function tokensRemainingInTier() public view returns (uint256) {
        return availableInCurrentTier;
    }

     function transferRemainingTokens() public onlyOwner {
         //require that sale is closed
         require(hasClosed());

         //require that tokens are still remaining after close
         require(availableInSale > 0);

         //calculate remaining seed tokens
         uint256 finalTokensRemaining = totalTokenVolume.sub(totalSupply_);

         //send remaining tokens to distribution pool wallet
         balances[distributionPoolWallet] = balances[distributionPoolWallet].add(finalTokensRemaining);
         emit CloseoutSale(distributionPoolWallet, finalTokensRemaining);
     }
}
