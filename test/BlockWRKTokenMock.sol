pragma solidity 0.4.24;

import "./../contracts/BlockWRKToken.sol";

contract BlockWRKTokenMock is BlockWRKToken {
    constructor(
        address _initialAccount,
        uint256 _initialBalance,
        address _distributionPoolWallet,
        address _inAppPurchaseWallet,
        address _feeAccount,
        bytes _signature2
    )
        public
    {
        balances[_initialAccount] = _initialBalance;
        feeAccount = _feeAccount;
        distributionPoolWallet = _distributionPoolWallet;
        inAppPurchaseWallet = _inAppPurchaseWallet;
        balances[distributionPoolWallet] = 1000;
        balances[inAppPurchaseWallet] = 1000;
        totalSupply_ = _initialBalance.add(2000);
        signatures[_signature2] = true;
    }
}
