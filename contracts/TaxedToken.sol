pragma solidity ^0.4.24;

import "./ERC865BasicToken.sol";

/**
 * @title Taxed token
 * @dev Version of BasicToken that allows for a fee on token transfers.
 * See https://github.com/OpenZeppelin/openzeppelin-solidity/pull/788
 * @author jsdavis28
 */
contract TaxedToken is ERC865BasicToken {
    /**
     * @dev Sets taxRate fee as public
     */
    uint8 public taxRate;

    /**
     * @dev Transfer tokens to a specified account after diverting a fee to a central account.
     * @param _to The receiving address.
     * @param _value The number of tokens to transfer.
     */
    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        uint256 fee = _value.mul(taxRate).div(100);
        uint256 taxedValue = _value.sub(fee);

        balances[_to] = balances[_to].add(taxedValue);
        emit Transfer(msg.sender, _to, taxedValue);
        balances[feeAccount] = balances[feeAccount].add(fee);
        emit Transfer(msg.sender, feeAccount, fee);

        return true;
    }

    /**
     * @dev Provides a taxed transfer on StandardToken's transferFrom() function
     * @param _from The address providing allowance to spend
     * @param _to The receiving address.
     * @param _value The number of tokens to transfer.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        uint256 fee = _value.mul(taxRate).div(100);
        uint256 taxedValue = _value.sub(fee);

        balances[_to] = balances[_to].add(taxedValue);
        emit Transfer(_from, _to, taxedValue);
        balances[feeAccount] = balances[feeAccount].add(fee);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, feeAccount, fee);

        return true; 
    }
}
