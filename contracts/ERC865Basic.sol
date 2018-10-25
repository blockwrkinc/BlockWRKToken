pragma solidity 0.4.24;

import '../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';

/**
 * @title ERC865Basic
 * @dev Simpler version of the ERC865 interface from https://github.com/adilharis2001/ERC865Demo
 * @author jsdavis28
 * @notice ERC865Token allows for users to pay gas costs to a delegate in an ERC20 token
 * https://github.com/ethereum/EIPs/issues/865
 */
 contract ERC865Basic is ERC20 {
     function _transferPreSigned(
         bytes _signature,
         address _from,
         address _to,
         uint256 _value,
         uint256 _fee,
         uint256 _nonce
     )
        internal;

     event TransferPreSigned(
         address indexed delegate,
         address indexed from,
         address indexed to,
         uint256 value);
}
