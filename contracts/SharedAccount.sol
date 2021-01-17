// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface ISharedAccount {
    function grantAdminRole(address newAdmin) external returns (bool);

    function removeAdminRole(address newAdmin) external returns (bool);
}

contract SharedAccount is Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    string name;
    string description;
    address redirectFeeTo;

    mapping(string => address) supportedERC20;

    event ReceiveDeposit(address sender, uint256 amount);

    event Withdraw(address to, uint256 amount);

    modifier supportErc20(string memory erc20) {
        require(
            supportedERC20[erc20] != address(0),
            "This shared account doesn't support this erc20"
        );
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Caller is not an Admin");
        _;
    }

    constructor(
        string memory accountName,
        string memory accountDescription,
        string memory erc20Name,
        address erc20Address,
        address feeTo
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
        name = accountName;
        description = accountDescription;
        supportedERC20[erc20Name] = erc20Address;
        redirectFeeTo = feeTo;
    }

    function grantAdminRole(address newAdmin) public returns (bool) {
        grantRole(ADMIN_ROLE, newAdmin);
        return true;
    }

    function removeAdminRole(address newAdmin) public returns (bool) {
        revokeRole(ADMIN_ROLE, newAdmin);
        return true;
    }

    function addErc20(string memory erc20Name, address erc20Address)
        public
        onlyAdmin
        returns (bool)
    {
        supportedERC20[erc20Name] = erc20Address;
        return true;
    }

    function removeErc20(string memory erc20Name)
        public
        onlyAdmin
        returns (bool)
    {
        supportedERC20[erc20Name] = address(0);
        return true;
    }

    function deposit(string memory erc20Name, uint256 amount)
        public
        supportErc20(erc20Name)
        returns (bool)
    {
        IERC20 erc20 = ERC20(supportedERC20[erc20Name]);
        erc20.transferFrom(_msgSender(), address(this), amount);
        emit ReceiveDeposit(_msgSender(), amount);
        return true;
    }

    function withdraw(
        string memory erc20Name,
        address to,
        uint256 amount
    ) public supportErc20(erc20Name) onlyAdmin returns (bool) {
        IERC20 erc20 = ERC20(supportedERC20[erc20Name]);

        uint256 fee = SafeMath.div(SafeMath.mul(amount, 4), 1000);
        uint256 total = amount - fee;
        erc20.approve(address(this), total);
        erc20.transferFrom(address(this), to, total);
        erc20.approve(address(this), fee);
        erc20.transferFrom(address(this), redirectFeeTo, fee);
        emit Withdraw(to, total);
        return true;
    }
}
