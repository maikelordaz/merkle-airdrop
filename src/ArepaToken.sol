// SPDX-License-Identifier: MIT

/// @notice just a test token to airdrop

pragma solidity 0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ArepaToken is ERC20, Ownable {
    constructor() ERC20("Arepa", "AREPA") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
