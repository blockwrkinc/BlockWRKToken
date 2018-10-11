pragma solidity ^0.4.24;

import "./../contracts/TaxedToken.sol";

contract TaxedTokenMock is TaxedToken {
    constructor(
        address _initialAccount,
        uint256 _initialBalance,
        address _feeAccount,
        uint8 _taxRate
    )
        public
    {
        balances[_initialAccount] = _initialBalance;
        totalSupply_ = _initialBalance;
        feeAccount = _feeAccount;
        taxRate = _taxRate;
    }
}
