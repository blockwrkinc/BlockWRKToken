pragma solidity ^0.4.24;

contract hashTesting {
    constructor() public {}
    //Generates a hashed message from transaction arguments
    function transactionDetails(address _to, uint256 _value, uint256 _fee, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(_to, _value, _fee, _nonce);
    }

    // Builds a prefixed hash for verification of message
    function prefixed(bytes32 hash) public pure returns (bytes32) {
        return keccak256("\x19Ethereum Signed Message:\n32", hash);
    }
}
