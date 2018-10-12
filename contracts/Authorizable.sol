pragma solidity ^0.4.24;

import "../../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Authorizable
 * @dev The Authorizable contract allows the owner to set a number of additional
 * acccounts with limited administrative privileges to simplify user permissions.
 * Only the contract owner can add or remove authorized accounts.
 * @author jsdavis28
 */
contract Authorizable is Ownable {
    using SafeMath for uint256;

    address[] public authorized;
    mapping(address => bool) internal authorizedIndex;
    uint8 public numAuthorized;

    /**
     * @dev The Authorizable constructor sets the original `owner` of the contract
     * as authorized.
     */
    constructor() public {
        authorized.length = 2;
        authorized[1] = msg.sender;
        authorizedIndex[msg.sender] = true;
        numAuthorized = 1;
    }

    /**
     * @dev Throws if called by any account other than an authorized account.
     */
    modifier onlyAuthorized {
        require(isAuthorized(msg.sender));
        _;
    }

    /**
     * @dev Allows the current owner to add an authorized account.
     * @param _account The address being added as authorized.
     */
    function addAuthorized(address _account) public onlyOwner {
        if (authorizedIndex[_account] == false) {
        	authorizedIndex[_account] = true;
        	authorized.length++;
        	authorized[authorized.length.sub(1)] = _account;
        	numAuthorized++;
        }
    }

    /**
     * @dev Validates whether an account is authorized for enhanced permissions.
     * @param _account The address being evaluated.
     */
    function isAuthorized(address _account) public constant returns (bool) {
        if (authorizedIndex[_account] == true) {
        	return true;
        }

        return false;
    }

    /**
     * @dev Allows the current owner to remove an authorized account.
     * @param _account The address to remove from authorized.
     */
    function removeAuthorized(address _account) public onlyOwner {
        authorizedIndex[_account] = false;
        numAuthorized--;
    }
}
