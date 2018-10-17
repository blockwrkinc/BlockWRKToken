# BlockWRKToken
BlockWRK token and ICO contracts

The BlockWRK token (WRK) is ERC20-compliant, with additional features to support [taxed token](https://github.com/OpenZeppelin/openzeppelin-solidity/issues/787) 
for transfers outside the application and [ERC865 functionality](https://github.com/ethereum/EIPs/issues/865) 
for internal tranfers that abstract gas costs away from the user, allowing a delegate 
(in this case, the application) to pay gas in Ether and then be reimbursed in WRK. 

Note(s) to auditor: 
- All unit tests passing. Development completed as of 1539811966. 

- truffle.js is set for testing with Ganache. 

- Contract constructors may contain test data used during Ropsten deployment, which should be commented out before running tests in Truffle. 
