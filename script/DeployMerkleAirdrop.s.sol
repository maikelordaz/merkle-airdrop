// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20} from "src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {ArepaToken} from "src/ArepaToken.sol";
import {console} from "forge-std/console.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT =
        0xfd5df8985e738a5e88cd7157ad9d1bb857ccecbd9b93c7ac26097875f6dca373;
    // 4 users, 25 Arepa tokens each
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);

    // Deploy the airdrop contract and Arepa token contract
    function deployMerkleAirdrop() public returns (MerkleAirdrop, ArepaToken) {
        vm.startBroadcast();
        ArepaToken arepaToken = new ArepaToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(arepaToken));
        // Send Arepa tokens -> Merkle Air Drop contract
        arepaToken.mint(arepaToken.owner(), AMOUNT_TO_TRANSFER);
        IERC20(arepaToken).transfer(address(airdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (airdrop, arepaToken);
    }

    function run() external returns (MerkleAirdrop, ArepaToken) {
        return deployMerkleAirdrop();
    }
}
