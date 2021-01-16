pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeDai is ERC20 {
    constructor() ERC20("FakeDai", "FDAI") {}

    function mint(address user) public {
        _mint(user, SafeMath.mul(100, 10**decimals()));
    }
}
