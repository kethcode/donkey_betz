// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Mint.sol";

contract Roles is AccessControl, Ownable {
    using SafeMath for uint256;

    using Counters for Counters.Counter;
    Counters.Counter private tokenIdsCounter;

    Mint private mint;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // mapping(address => uint256) public tokensMinted;
    mapping(address => bool) public minters;
    mapping(bytes32 => mapping(address => bool)) public roles;
    // Stores the address of the owner of a specific token.
    mapping(uint256 => address) public tokenOwner;
    mapping(address => mapping(uint256 => bool)) public tokenOfOwner;
    // mapping(uint256 => address) public tokenOwner;

    event RoleGranted(address user, bytes32 role);
    event RoleRevoked(address user, bytes32 role);
    event TokenMinted(address user, uint256 tokenId);

    constructor(address _mintAddress) {
        mint = Mint(_mintAddress);
    }

    function grantRole(
        address user,
        bytes32 role
    ) public onlyOwner onlyRole(ADMIN_ROLE) {
        require(role == MINTER_ROLE || role == ADMIN_ROLE, "Invalid role");
        _grantRole(role, user);

        if (role == MINTER_ROLE) {
            minters[user] = true;
        }
        emit RoleGranted(user, role);
    }

    function revokeRole(
        address user,
        bytes32 role
    ) public onlyOwner onlyRole(ADMIN_ROLE) {
        require(role == MINTER_ROLE || role == ADMIN_ROLE, "Invalid role");
        _revokeRole(role, user);

        if (role == MINTER_ROLE) {
            minters[user] = false;
        }
        emit RoleRevoked(user, role);
    }

    function mintTokens(
        address user,
        string memory _metadataHash
    ) public onlyRole(MINTER_ROLE) {
        require(
            roles[MINTER_ROLE][user] == true,
            "User does not have the MINTER_ROLE"
        );

        // Mint the token`
        address mintedTo;
        uint256 tokenId;
        string memory metadataHash;

        (mintedTo, tokenId, metadataHash) = mint.mint(user, _metadataHash);
        tokenOwner[tokenId] = user;
        tokenOfOwner[user][tokenId] = true;
        emit TokenMinted(user, tokenId);
    }

    function hasRole(
        bytes32 role,
        address user
    ) public view override returns (bool) {
        return roles[role][user];
    }

    function updateContract(bytes memory _data) public onlyRole(ADMIN_ROLE) {
        // Code to update the contract
    }
}
