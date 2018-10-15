# BlockWRKToken
BlockWRK token and ICO contracts

The BlockWRK token (WRK) is ERC20-compliant, with additional features to support [taxed token](https://github.com/OpenZeppelin/openzeppelin-solidity/issues/787) 
for transfers outside the application and [ERC865 functionality](https://github.com/ethereum/EIPs/issues/865) 
for internal tranfers that abstract gas costs away from the user, allowing a delegate 
(in this case, the application) to pay gas in Ether and then be reimbursed in WRK. 

Note(s) to auditor: OpenZeppelin contract imports may need to be edited for 
compiling and testing, depending on location of the directory in relation 
to node_modules on your local machine. 
