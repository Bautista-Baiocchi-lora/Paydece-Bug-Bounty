// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@test/IFaucet.sol";

contract E20 is ERC20, IFaucet {
    uint8 public immutable dp;

    constructor(uint8 newDp, string memory name, string memory symbol) ERC20(name, symbol) {
        dp = newDp;
    }

    function decimals() public view virtual override returns (uint8) {
        return dp;
    }

    function faucet(uint256 amount) public {
        _mint(msg.sender, amount * (10**dp));
    }
}