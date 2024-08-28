// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MerkleAirdrop is EIP712 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    address[] claimers;
    bytes32 private immutable merkleRoot; // The root is always on-chain, the proof is off-chain and should never change
    IERC20 private immutable airdropToken;

    mapping(address claimer => bool claimed) private hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claimed(address account, uint256 amount);
    event MerkleRootUpdated(bytes32 newMerkleRoot);

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    constructor(
        bytes32 _merkleRoot,
        IERC20 _airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        merkleRoot = _merkleRoot;
        airdropToken = _airdropToken;
    }

    /**
     * @notice Claim for another account
     * @param account The account to claim for
     * @param amount The amount to claim
     * @param merkleProof The merkle proof to verify the claim. Stored off-chain
     * @dev v, r, s are the signature
     * @dev Here the caller will pay the gas for the transaction but `account` will receive the tokens
     */
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (hasClaimed[account]) revert MerkleAirdrop__AlreadyClaimed();

        // Check the signature
        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) revert MerkleAirdrop__InvalidSignature();

        // Verify the merkle proof
        // calculate the leaf node hash
        // Calculate using the account and the amount, the hash -> leaf node
        // We encode the values to be hashed together
        // We hash it twice to avoid hash collisions, this is to avoid second pre-image attacks
        // It can be done once, but the standard is to do it twice
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf))
            revert MerkleAirdrop__InvalidProof();

        hasClaimed[account] = true;
        emit Claimed(account, amount);
        airdropToken.safeTransfer(account, amount);
    }

    /// @dev message we expect to have been signed
    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    function getMerkleRoot() external view returns (bytes32) {
        return merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return airdropToken;
    }

    // verify whether the recovered signer is the expected signer/the account to airdrop tokens for
    function _isValidSignature(
        address signer,
        bytes32 digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (bool) {
        // could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        (address actualSigner, , ) = ECDSA.tryRecover(digest, _v, _r, _s);
        return (actualSigner == signer);
    }

    // function _isValidSignature(
    //     address signer,
    //     bytes32 digest,
    //     uint8 _v,
    //     bytes32 _r,
    //     bytes32 _s
    // )
    // internal view returns (bool) {
    //     bytes memory signature = abi.encode(_v, _r, _s);
    //     return SignatureChecker.isValidSignatureNow(signer, digest, signature);
    // }
}
