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
        uint256 tokenId;
        string hashVc;
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

    function register(address to, string calldata name, string calldata hashVc) public onlyOwner {
        counter = counter+1;
        require(bytes(identities[to].name).length == 0, "You already have an identity associated with that address");
        require(bytes(name).length != 0 && bytes(hashVc).length != 0, "Name or hash can't be empty");
        identities[to] = Identity({
            name: name,
            tokenId: counter,
            hashVc: hashVc
        });
        lock = false;
        safeMint(to, counter);
        lock = true;
    }

    function unregister(address to) public onlyOwner {
        lock = false;
        super._burn(identities[to].tokenId);
        lock = true;
        identities[to].name = "";
        identities[to].hashVc = "";
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
