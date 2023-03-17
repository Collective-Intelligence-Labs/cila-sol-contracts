// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./AggregateState.sol";
import "./proto/command.proto.sol";
import "./proto/event.proto.sol";


contract NFTsState is AggregateState {

    mapping (bytes32 => address) public items;
    bytes32[] public ids;


    function on(DomainEvent memory evnt) internal override { 

        if (evnt.evnt_type == DomainEventType.NFT_MINTED) {
            (bool success, , NFTMintedPayload memory payload) = NFTMintedPayloadCodec.decode(0, evnt.evnt_payload, uint64(evnt.evnt_payload.length));
            require(success, "NFTMintedPayload deserialization failed");

            onMinted(payload);
        }

        if (evnt.evnt_type == DomainEventType.NFT_TRANSFERED) {
            (bool success, , NFTTransferedPayload memory payload) = NFTTransferedPayloadCodec.decode(0, evnt.evnt_payload, uint64(evnt.evnt_payload.length));
            require(success, "NFTTransferedPayload deserialization failed");

            onTransfered(payload);
        }
        
    }

    function onMinted(NFTMintedPayload memory payload) private {
        bytes32 hash = bytes32(payload.hash);
        address owner = bytesToAddress(payload.owner);

        items[hash] = owner;
        ids.push(hash);
    }

    function onTransfered(NFTTransferedPayload memory payload) private {
        bytes32 hash = bytes32(payload.hash);
        address to = bytesToAddress(payload.to);

        items[hash] = to;
    }

    function clear() internal override { 
        for (uint i = 0; i < ids.length; i++) {
            delete items[ids[i]];
            delete ids[i];
        }
    }
    
    function bytesToAddress(bytes memory data) public pure returns (address) { // todo: move to a preprocessor
        require(data.length == 20, "Invalid address format");
        address addr;
        assembly {
            addr := mload(add(data, 20))
        }
        return addr;
    }
}