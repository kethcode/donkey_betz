// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Roles.sol";
import "./Users.sol";

contract Mint is ERC721URIStorage, Ownable, AccessControl {
    // Added SafeMath
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdsCounter;

    // Accessing Roles.sol
    Roles private roles;
    // Accessing Users.sol
    Users private user;

    // Stores if a token has been minted to a specific user
    mapping(address => mapping(uint256 => bool)) public tokenOfOwner;
    // mapping(uint256 => address) public tokenOwner;

    // Stores the address of the owner of a specific token.
    mapping(address => bool) public minters;
    mapping(uint256 => string) public tokensMetadata;

    event TokenMinted(
        address indexed _wallet,
        uint256 indexed tokenId,
        string metadataHash
    );

    constructor(address _roles, address _user) {
        ERC721("Donkey Betz", "DONK");
        roles = Roles(_roles);
        user = Users(_user);
    }

    modifier onlyMinter() {
        require(
            roles.hasRole(roles.MINTER_ROLE, msg.sender),
            "Sender is not a minter"
        );
        _;
    }

    function mint(
        address _wallet,
        string memory _metadataHash
    ) public onlyMinter returns (address, uint256, string memory) {
        // Get the next available _tokenIds
        uint256 tokenId = tokenIdsCounter.current();
        require(_wallet != address(0), "Mint to the zero address");
        require(
            tokenOfOwner[_wallet][tokenId] == false,
            "The token has already been minted"
        );

        // mint the token
        ERC721(_baseURI)._mint(_wallet, tokenId, _metadataHash);
        tokenOfOwner[_wallet][tokenId] = true;
        tokenOfOwner[tokenId] = _wallet;
        tokensMetadata[tokenId] = _metadataHash;
        emit TokenMinted(_wallet, tokenId, _metadataHash);
        return (_wallet, tokenId, _metadataHash);
    }

    function burn(address _owner, uint256 _tokenId) public {
        require(tokenOfOwner[_owner][_tokenId] == true, "Token not minted");
        super._burn(_tokenId);
        tokenOfOwner[_owner][_tokenId] = false;
        delete tokenOfOwner[_tokenId];
        delete tokensMetadata[_tokenId];
    }

    // Modifier to make NFT Soulbound and non-transferable
    modifier canNotTransfer(uint256 _tokenId) {
        require(
            tokenOfOwner[msg.sender][_tokenId] == msg.sender,
            "This token is SOUL BOUND."
        );
        _;
    }

    function grantMintership(address _minter) public {
        require(
            roles.hasRole(roles.MINTER_ROLE, msg.sender),
            "Sender must have MINTER_ROLE to grant mintership"
        );
        minters[_minter] = true;
    }

    function revokeMintership(address _minter) public {
        require(
            roles.hasRole(roles.MINTER_ROLE, msg.sender),
            "Sender must have MINTER_ROLE to revoke mintership"
        );
        minters[_minter] = false;
    }

    // Allows transfer of any tokens that are not the Soul Bound token
    function transfer(
        address payable _to,
        uint256 _tokenId
    ) public canNotTransfer(tokenOfOwner) {
        require(
            tokenOfOwner[_tokenId] == msg.sender,
            "user is not the owner of the token"
        );
        require(_to != address(0), "invalid address");
        super._transfer(msg.sender, _to, _tokenId);
        delete tokenOfOwner[msg.sender][_tokenId];
        tokenOfOwner[_to][_tokenId] = true;
        tokenOwner[_tokenId] = _to;
    }

    // The following functions are overrides required by Solidity.
    // Convert uint256 to string via abi.encodePacked()

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        return "ipfs://" + tokensMetadata[_tokenId];
    }
}
