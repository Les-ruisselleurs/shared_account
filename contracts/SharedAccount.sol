// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract SharedAccount is Ownable, AccessControl {
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    string private _name;
    bool private _private;

    ERC20 daiInstance;

    constructor(
        address daiAddress,
        string memory accountName,
        bool isPrivate
    ) {
        daiInstance = ERC20(daiAddress);
        _setupRole(CREATOR_ROLE, _msgSender());
        _name = accountName;
        _private = isPrivate;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function deposit(uint256 amount) public returns (bool) {
        daiInstance.transferFrom(_msgSender(), address(this), amount);
        return true;
    }

    function balance() public view returns (uint256) {
        if (_private) {
            require(owner() == _msgSender(), "Only owner can see the balance");
            return 0;
        }
        uint256 daiBalance = daiInstance.balanceOf(address(this));
        return daiBalance;
    }

    function withdraw(address to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        daiInstance.approve(address(this), amount);
        daiInstance.transferFrom(address(this), to, amount);
        return true;
    }
}
