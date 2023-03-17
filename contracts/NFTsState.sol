// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./AggregateState.sol";
import "./Events.sol";
import "./proto/command.proto.sol";


contract NFTsState is AggregateState {

    mapping (bytes32 => address) public items;
    bytes32[] public ids;


    function on(DomainEvent memory evnt) internal override { 
        if (evnt.t == DomainEventType.NFTMinted) {
           onMinted(evnt);
        } else if (evnt.t == DomainEventType.NFTTransfered) {
           onTransfered(evnt);
        }
    }

    function onMinted(DomainEvent memory evnt) private {
        NFTMintedPayload memory ep = abi.decode(evnt.payload, (NFTMintedPayload));
        items[ep.hash] = ep.owner;
        ids.push(ep.hash);
    }

    function onTransfered(DomainEvent memory evnt) private {
        NFTTransferedPayload memory ep = abi.decode(evnt.payload, (NFTTransferedPayload));
        items[ep.hash] = ep.to;
    }

    function clear() internal override { 
        for (uint i = 0; i < ids.length; i++) {
            delete items[ids[i]];
            delete ids[i];
        }
    }
    
}