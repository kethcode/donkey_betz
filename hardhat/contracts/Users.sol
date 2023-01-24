// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./Roles.sol";
import "./Mint.sol";

contract Users {
    // Starting ROLE for contract
    Roles private roles;

    // Contract for minting NFTs
    Mint private mint;

    // Base entry role
    bytes32 public role = keccak256("MINTER_ROLE");

    // Struct for creating the user
    struct User {
        address wallet;
        string name;
        string email;
        string username;
        string metadataHash;
        uint256 tokenId;
    }

    // user address payable for later updates
    // address payable public user;

    // mapping Struct to users wallet
    mapping(address => User) public users;

    // Mappings to verifiy that the Username and Email are unique
    mapping(string => address) public usernameToAddress;
    mapping(string => address) public emailToAddress;

    // event for new user
    event UserCreated(address indexed user, string username);
    event UserUpdated(address indexed wallet);

    // Constructor for deploying Roles.sol
    constructor(address _roles, address _mint) {
        require(_roles != address(0), "Roles address is not vailid");
        require(_mint != address(0), "Mint address is not vailid");
        roles = Roles(_roles);
        mint = Mint(_mint);
    }

    // requiring that the User have MINTER_ROLE to be aloud to mint NFTs
    modifier onlyMinter() {
        require(
            roles.hasRole(roles.MINTER_ROLE, msg.sender),
            "Sender must have MINTER_ROLE to mint new tokens."
        );
        _;
    }

    // Create user
    function createUser(
        address _wallet,
        string memory _name,
        string memory _email,
        string memory _username,
        string memory _metadataHash
    ) public onlyMinter {
        require(
            emailToAddress[_email] == address(0),
            "that Email is already taken"
        );
        require(
            usernameToAddress[_username] == address(0),
            "that Username is already taken"
        );
        require(
            users[_wallet].wallet == address(0),
            "Address is already taken"
        );

        // Storing tokenId in the user struct and grating MINTER_ROLE
        users[_wallet].tokenId = mint.mint(_wallet, _metadataHash);
        uint256 tokenId = users[_wallet].tokenId++;
        roles.grantRole(_wallet, role);

        users[_wallet] = User(
            _wallet,
            _name,
            _email,
            _username,
            _metadataHash,
            tokenId
        );
        emailToAddress[_email] = _wallet;
        usernameToAddress[_username] = _wallet;

        emit UserCreated(_wallet, _username);
    }

    //
    function getTokenIdByUser(address _wallet) public view returns (uint256) {
        return users[_wallet];
    }

    // Finds user by address
    function getUserByAddress(
        address _user
    ) public view returns (string memory, string memory) {
        return (users[_user].name, users[_user].username);
    }

    // Search for user by username
    function getUserByUsername(
        string memory _username
    ) public view returns (address, string memory) {
        User storage userByUsername = users[usernameToAddress[_username]];
        return (userByUsername.wallet, userByUsername.name);
    }

    function updateUserInfo(
        address _wallet,
        string memory _metadataHash,
        string memory _name,
        string memory _email,
        string memory _username
    ) public onlyMinter {
        // Check that the new email is not already associated with another user

        // Check that the new metadataHash is not already associated with another user
        if (
            emailToAddress[_email] != address(0) &&
            emailToAddress[_email] != _wallet
        ) {
            revert("The email is already taken");
        }

        // Check that the new name is not already associated with another user
        if (users[_wallet] != 0) {
            revert("The tokenId is already associated with another user");
        }

        // Check that the new username is not already associated with another user
        if (
            usernameToAddress[_username] != address(0) &&
            usernameToAddress[_username] != _wallet
        ) {
            revert("The username is already taken");
        }

        // Update the email mapping
        if (emailToAddress[_email] == _wallet) {
            delete emailToAddress[_email];
        }
        emailToAddress[_email] = _wallet;

        // Update the username mapping
        if (usernameToAddress[_username] == _wallet) {
            delete usernameToAddress[_username];
        }
        usernameToAddress[_username] = _wallet;

        // Update the user struct
        User storage userToUpdate = users[_wallet];
        userToUpdate.name = _name;
        userToUpdate.email = _email;
        userToUpdate.username = _username;
        userToUpdate.metadataHash = _metadataHash;

        // Update the tokenId mapping
        users[_wallet] = users[_wallet].tokenId;

        // Emit an event to signal that the user's information has been updated
        emit UserUpdated(_wallet);
    }
}
