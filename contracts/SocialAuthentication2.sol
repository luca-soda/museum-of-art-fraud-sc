// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract SocialAuthentication {
    constructor() {}
    
    struct Identity {
        string name;
        string surname;
        uint256 tokenId;
    }

    mapping(address => Identity) identities;
    uint256 counter = 0;

    bool lock = true;

    function register(address to, string calldata name, string calldata surname) public {
        counter = counter+1;
        require(bytes(identities[to].name).length == 0, "You already have an identity associated with that address");
        require(bytes(name).length != 0 && bytes(surname).length != 0, "Name or surname can't be empty");
        identities[to] = Identity({
            name: name,
            surname: surname,
            tokenId: counter
        });
    }

    function unregister(address to) public {
        identities[to].name = "";
        identities[to].surname = "";
        identities[to].tokenId = 0;
    }

    function identity(address to) public view returns(Identity memory id) {
        return identities[to];
    }
}
