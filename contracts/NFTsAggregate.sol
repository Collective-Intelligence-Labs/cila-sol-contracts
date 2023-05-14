// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Aggregate.sol";
import "./NFTsState.sol";
import "./Utils.sol";
import "./proto/command.proto.sol";
import "./proto/event.proto.sol";


contract NFTsAggregate is Aggregate {

    NFTsState state;

    constructor(NFTsState _state, uint256 _version) {
        state = _state;
        version = _version;
    }

    function mint(bytes memory hash, string memory owner) public {
        NFTMintedPayload memory e;
        e.hash = hash;
        e.owner = abi.encodePacked(owner);
        //applyEvent(e);
        state.on(e);
        addEvent(DomainEventType.NFT_MINTED, NFTMintedPayloadCodec.encode(e));
    }

    function transfer(bytes32 hash, bytes memory to) public {
        //require(sender is an owner of the NFT);
        NFTTransferedPayload memory e;
        //e.hash = hash;
        e.from = abi.encodePacked(state.nfts(hash));
        e.to = to;
        //applyEvent(evnt);
        state.on(e);
        addEvent(DomainEventType.NFT_MINTED, NFTTransferedPayloadCodec.encode(e));
    }

    function addEvent(DomainEventType event_type, bytes memory payload) private {
        DomainEvent memory evnt;
        evnt.evnt_idx = uint64(version++);
        evnt.evnt_type = event_type;
        evnt.evnt_payload = payload;
        changes.push(evnt);
    }
}