# BlockWRKToken
BlockWRK token and ICO contracts

The BlockWRK token (WRK) is ERC20-compliant, with additional features to support <a href="https://github.com/OpenZeppelin/openzeppelin-solidity/issues/787">taxed token</a> 
for transfers outside the application and <a href="https://github.com/ethereum/EIPs/issues/865">ERC865 functionality</a> 
for internal tranfers that abstract gas costs away from the user, allowing a delegate 
(in this case, the application) to pay gas in Ether and then be reimbursed in WRK. 

Updates: 
* Code has successfully passed audit from QuillHash, 31 October 2018: <a href="https://blockwrkinc.github.io/contract_audit.html">Full text of the report</a>. 
