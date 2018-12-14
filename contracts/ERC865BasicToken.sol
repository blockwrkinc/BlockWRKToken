pragma solidity 0.4.24;

import "./ERC865Basic.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

/**
 * @title ERC865BasicToken
 * @dev Simpler version of the ERC865 token from https://github.com/adilharis2001/ERC865Demo
 * @author jsdavis28
 * @notice ERC865Token allows for users to pay gas costs to a delegate in an ERC20 token
 * https://github.com/ethereum/EIPs/issues/865
 */

 contract ERC865BasicToken is ERC865Basic, StandardToken {
    /**
     * @dev Sets internal variables for contract
     */
    address internal feeAccount;
    mapping(bytes => bool) internal signatures;

    /**
     * @dev Allows a delegate to submit a transaction on behalf of the token holder.
     * @param _signature The signature, issued by the token holder.
     * @param _to The recipient's address.
     * @param _value The amount of tokens to be transferred.
     * @param _fee The amount of tokens paid to the delegate for gas costs.
     * @param _nonce The transaction number.
     */
    function _transferPreSigned(
        bytes _signature,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        internal
    {
        //Pre-validate transaction
        require(_to != address(0));
        require(signatures[_signature] == false);

        //Create a hash of the transaction details
        bytes32 hashedTx = _transferPreSignedHashing(_to, _value, _fee, _nonce);

        //Obtain the token holder's address and check balance
        address from = _recover(hashedTx, _signature);
        require(from == _from);
        uint256 total = _value.add(_fee);
        require(total <= balances[from]);

        //Transfer tokens
        balances[from] = balances[from].sub(_value).sub(_fee);
        balances[_to] = balances[_to].add(_value);
        balances[feeAccount] = balances[feeAccount].add(_fee);

        //Mark transaction as completed
        signatures[_signature] = true;

        //TransferPreSigned ERC865 events
        emit TransferPreSigned(msg.sender, from, _to, _value);
        emit TransferPreSigned(msg.sender, from, feeAccount, _fee);
        
        //Transfer ERC20 events
        emit Transfer(from, _to, _value);
        emit Transfer(from, feeAccount, _fee);
    }

    /**
     * @dev Creates a hash of the transaction information passed to transferPresigned.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     * @return A copy of the hashed message signed by the token holder, with prefix added.
     */
    function _transferPreSignedHashing(
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        internal
        returns (bytes32)
    {
        //Create a copy of thehashed message signed by the token holder
        bytes32 hash = keccak256(abi.encodePacked(_to, _value, _fee, _nonce));

        //Add prefix to hash
        return _prefix(hash);
    }

    /**
     * @dev Adds prefix to the hashed message signed by the token holder.
     * @param _hash The hashed message (keccak256) to be prefixed.
     * @return Prefixed hashed message to return from _transferPreSignedHashing.
     */
    function _prefix(bytes32 _hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    /**
     * @dev Validate the transaction information and recover the token holder's address.
     * @param _hash A prefixed version of the hash used in the original signed message.
     * @param _sig The signature submitted by the token holder.
     * @return The token holder/transaction signer's address.
     */
    function _recover(bytes32 _hash, bytes _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        //Check the signature length
        if (_sig.length != 65) {
            return (address(0));
        }

        //Split the signature into r, s and v variables
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        //Version of signature should be 27 or 28, but 0 and 1 are also possible
        if (v < 27) {
            v += 27;
        }

        //If the version is correct, return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }
}
