// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract SocialAuthentication is ERC721, Pausable, Ownable, ERC721Burnable {
    constructor() ERC721("SocialAuthentication", "SA") {}
    struct Identity {
        string name;
        string surname;
        uint256 tokenId;
    }

    mapping(address => Identity) identities;
    uint256 counter = 0;

    bool lock = true;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function register(address to, string calldata name, string calldata surname) public onlyOwner {
        counter = counter+1;
        require(bytes(identities[to].name).length == 0, "You already have an identity associated with that address");
        require(bytes(name).length != 0 && bytes(surname).length != 0, "Name or surname can't be empty");
        identities[to] = Identity({
            name: name,
            surname: surname,
            tokenId: counter
        });
        lock = false;
        safeMint(to, counter);
        lock = true;
    }

    function unregister(address to) public onlyOwner {
        this.burn(identities[to].tokenId);
        identities[to].name = "";
        identities[to].surname = "";
        identities[to].tokenId = 0;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal whenNotPaused override {
        require(!lock, "Cannot transfer");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function identity(address to) public view returns(Identity memory id) {
        return identities[to];
    }
}
