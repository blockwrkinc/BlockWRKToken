pragma solidity ^0.4.24;

import "./TaxedToken.sol";
import "./Authorizable.sol";

/**
 * @title BlockWRKToken
 * @author jsdavis28
 */

contract BlockWRKToken is TaxedToken, Authorizable {
    /**
     * @dev Sets token information.
     */
    string public name = "BlockWRK";
    string public symbol = "WRK";
    uint8 public decimals = 4;
    uint256 public INITIAL_SUPPLY;

    /**
     * @dev Sets public variables for BlockWRK token.
     */
    address public distributionPoolWallet;
    address public inAppPurchaseWallet;
    address public reservedTokenWallet;
    uint256 public premineDistributionPool;
    uint256 public premineReserved;

    /**
     * @dev Sets private variables for custom token functions.
     */
    uint256 internal decimalValue = 10000;

    constructor() public {
        //feeAccount =
        //distributionPoolWallet =
        //reservedTokenWallet =

        //premineDistributionPool = 56000000000000;
        //premineReserved = 20000000000000;
        //INITIAL_SUPPLY = premineDistributionPool.add(premineReserved);
        //balances[distributionPoolWallet] = premineDistributionPool;
        //balances[reservedTokenWallet] = premineReserved;
        totalSupply_ = INITIAL_SUPPLY;

        //remove after testing
        INITIAL_SUPPLY = 120000000;
        balances[msg.sender] = INITIAL_SUPPLY;

        //need to determine if feeAccount will be the same as reservedTokenWallet
        feeAccount = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        taxRate = 2;
    }

    /**
     * @dev Allows App to distribute WRK tokens to users.
     * This function will be called by authorized from within the App.
     * @param _to The recipient's BlockWRK address.
     * @param _value The amount of WRK to transfer.
     */
    function inAppTokenDistribution(
        address _to,
        uint256 _value
    )
        public
        onlyAuthorized
        returns (bool)
    {
        require(_value <= balances[distributionPoolWallet]);
        require(_to != address(0));

        balances[distributionPoolWallet] = balances[distributionPoolWallet].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(distributionPoolWallet, _to, _value);

        return true;
    }

    /**
     * @dev Allows App to process fiat payments for WRK tokens, charging a fee in WRK.
     * This function will be called by authorized from within the App.
     * @param _to The buyer's BlockWRK address.
     * @param _value The amount of WRK to transfer.
     * @param _fee The fee charged in WRK for token purchase.
     */
    function inAppTokenPurchase(
        address _to,
        uint256 _value,
        uint256 _fee
    )
        public
        onlyAuthorized
        returns (bool)
    {
        require(_value <= balances[inAppPurchaseWallet]);
        require(_to != address(0));

        balances[inAppPurchaseWallet] = balances[inAppPurchaseWallet].sub(_value);
        uint256 netAmount = _value.sub(_fee);
        balances[_to] = balances[_to].add(netAmount);
        emit Transfer(inAppPurchaseWallet, _to, netAmount);
        balances[feeAccount] = balances[feeAccount].add(_fee);
        emit Transfer(inAppPurchaseWallet, feeAccount, _fee);

        return true;
    }

    /**
     * @dev Allows owner to retrieve any Ether sent to this contract.
     */
    function rescueLostEther() public onlyOwner returns (bool) {
        owner.transfer(address(this).balance);
    }

    /**
     * @dev Allows owner to set the percentage fee charged by TaxedToken on external transfers.
     * @param _newRate The amount to be set.
     */
    function setTaxRate(uint8 _newRate) public onlyOwner returns (bool) {
        taxRate = _newRate;

        return true;
    }

    /**
     * @dev Allows owner to set the fee account to receive transfer fees.
     * @param _newAddress The address to be set.
     */
    function setFeeAccount(address _newAddress) public onlyOwner returns (bool) {
        require(_newAddress != address(0));
        feeAccount = _newAddress;

        return true;
    }

    /**
     * @dev Allows owner to set the wallet that holds WRK for sale via in-app purchases with fiat.
     * @param _newAddress The address to be set.
     */
    function setInAppPurchaseWallet(address _newAddress) public onlyOwner returns (bool) {
        require(_newAddress != address(0));
        inAppPurchaseWallet = _newAddress;

        return true;
    }

    /**
     * @dev Allows authorized to act as a delegate to transfer a pre-signed transaction for ERC865
     * @param _signature The pre-signed message.
     * @param _to The token recipient.
     * @param _value The amount of WRK to send the recipient.
     * @param _fee The fee to be paid in WRK (calculated by App off-chain).
     * @param _nonce The transaction number (stored in App off-chain).
     */
    function transactionHandler(
        bytes _signature,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        onlyAuthorized
        returns (bool)
    {
        _transferPreSigned(_signature, _from, _to, _value, _fee, _nonce);

        return true;
    }
}
