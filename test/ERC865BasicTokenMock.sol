pragma solidity ^0.4.24;

import "./../contracts/ERC865BasicToken.sol";

contract ERC865BasicTokenMock is ERC865BasicToken {
    constructor(
        address initialAccount,
        uint256 initialBalance,
        address _feeAccount,
        bytes _signature2
    )
        public
    {
        balances[initialAccount] = initialBalance;
        totalSupply_ = initialBalance;
        feeAccount = _feeAccount;
        signatures[_signature2] = true;
    }
}
