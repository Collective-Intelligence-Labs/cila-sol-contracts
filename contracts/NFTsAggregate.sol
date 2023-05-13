// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Aggregate.sol";
import "./NFTsState.sol";
import "./Utils.sol";
import "./proto/command.proto.sol";
import "./proto/event.proto.sol";


contract NFTsAggregate {

    NFTsState state;

    constructor() {
        state = new NFTsState();
    }

    function mint(bytes memory hash, string memory owner) public {
        NFTMintedPayload memory e;
        e.hash = hash;
        e.owner = abi.encodePacked(owner);
        //applyEvent(e);
    }

    function transfer(bytes32 hash, bytes memory to) public {
        NFTTransferedPayload memory e;
        //e.hash = hash;
        e.from = abi.encodePacked(state.nfts(hash));
        e.to = to;
        //applyEvent(evnt);
    }

}