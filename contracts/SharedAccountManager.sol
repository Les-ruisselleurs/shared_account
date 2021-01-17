// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";

import "./SharedAccount.sol";

contract SharedAccountManager is Context {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => EnumerableSet.AddressSet) private userToSharedAccounts;
    mapping(address => EnumerableSet.AddressSet) private sharedAccountsToUser;

    address feeAddress;

    //  This event is emitted when a new SharedAccount is created
    event SharedAccountCreated(address sharedAccountAddress);

    constructor(address feeTo) {
        feeAddress = feeTo;
    }

    function create(
        string memory name,
        string memory description,
        string memory erc20Name,
        address erc20Address
    ) public returns (bool) {
        SharedAccount sharedAccount =
            new SharedAccount(
                name,
                description,
                erc20Name,
                erc20Address,
                feeAddress
            );
        userToSharedAccounts[_msgSender()].add(address(sharedAccount));
        sharedAccountsToUser[address(sharedAccount)].add(_msgSender());
        emit SharedAccountCreated(address(sharedAccount));
        return true;
    }

    function mySharedAccounts() public view returns (address[] memory) {
        address[] memory sharedAccounts =
            new address[](
                EnumerableSet.length(userToSharedAccounts[_msgSender()])
            );
        for (uint256 i = 0; i < sharedAccounts.length; i++) {
            sharedAccounts[i] = address(
                EnumerableSet.at(userToSharedAccounts[_msgSender()], i)
            );
        }
        return sharedAccounts;
    }

    function grandAdminRole(address sharedAccount, address newAdmin)
        public
        returns (bool)
    {
        ISharedAccount account = ISharedAccount(sharedAccount);
        account.grantAdminRole(newAdmin);
        userToSharedAccounts[newAdmin].add(address(sharedAccount));
        sharedAccountsToUser[address(sharedAccount)].add(newAdmin);
        return true;
    }

    function revokeAdminRole(address sharedAccount, address oldAdmin)
        public
        returns (bool)
    {
        ISharedAccount account = ISharedAccount(sharedAccount);
        account.removeAdminRole(oldAdmin);
        userToSharedAccounts[oldAdmin].remove(sharedAccount);
        sharedAccountsToUser[sharedAccount].remove(oldAdmin);
        return true;
    }
}
