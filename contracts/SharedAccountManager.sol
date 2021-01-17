// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./SharedAccount.sol";

contract SharedAccountManager is Context {
    mapping(address => address[]) private sharedAccounts;

    //  This event is emitted when a new SharedAccount is created
    event SharedAccountCreated(address sharedAccountAddress);

    constructor() {}

    function create(
        string memory name,
        string memory description,
        string memory erc20Name,
        address erc20Address
    ) public returns (bool) {
        SharedAccount sharedAccount =
            new SharedAccount(name, description, erc20Name, erc20Address);
        sharedAccounts[_msgSender()].push(address(sharedAccount));
        emit SharedAccountCreated(address(sharedAccount));
        return true;
    }

    function mySharedAccounts() public view returns (address[] memory) {
        return sharedAccounts[_msgSender()];
    }
}
