// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Aggregate.sol";
import "./NFTsState.sol";
import "./proto/command.proto.sol";
import "./proto/event.proto.sol";

contract NFTsAggregate is Aggregate {

    constructor() {
        state = new NFTsState();
    }

    function handleCommand(Command memory cmd) internal override {

        if (cmd.cmd_type == CommandType.MINT_NFT) {
            (bool success, , MintNFTPayload memory payload) = MintNFTPayloadCodec.decode(0, cmd.cmd_payload, uint64(cmd.cmd_payload.length));
            require(success, "MintNFTPayload deserialization failed");

            mint(payload);
        } 
        
        if (cmd.cmd_type == CommandType.TRANSFER_NFT) {
            (bool success, , TransferNFTPayload memory payload) = TransferNFTPayloadCodec.decode(0, cmd.cmd_payload, uint64(cmd.cmd_payload.length));
            require(success, "TransferNFTPayload deserialization failed");
            
            transfer(payload);
        }
    }

    function mint(MintNFTPayload memory payload) private {
        NFTsState s = NFTsState(address(state));

        bytes32 hash = bytes32(payload.hash);
        address owner = bytesToAddress(payload.owner);
        require(s.items(hash) == address(0), "NFT with such hash is already minted");

        NFTMintedPayload memory evnt_payload; 
        evnt_payload.hash = payload.hash;
        evnt_payload.owner = payload.owner;

        DomainEvent memory evnt;
        evnt.evnt_idx = eventsCount; // counter will be incremented in applyEvent
        evnt.evnt_type = DomainEventType.NFT_MINTED;
        evnt.evnt_payload = NFTMintedPayloadCodec.encode(evnt_payload);

        applyEvent(evnt);
    }


    function transfer(TransferNFTPayload memory payload) private {
        NFTsState s = NFTsState(address(state));
        
        bytes32 hash = bytes32(payload.hash);
        address to = bytesToAddress(payload.to);
        require(s.items(hash) != to, "NFT can not be transferred to its current owner");

        NFTTransferedPayload memory evnt_payload;
        evnt_payload.hash = payload.hash;
        evnt_payload.from = abi.encodePacked(s.items(hash));
        evnt_payload.to = payload.to;
        
        DomainEvent memory evnt;
        evnt.evnt_idx = eventsCount; // counter will be incremented in applyEvent
        evnt.evnt_type = DomainEventType.NFT_TRANSFERED;
        evnt.evnt_payload = NFTTransferedPayloadCodec.encode(evnt_payload);

        applyEvent(evnt);
    }

    function bytesToAddress(bytes memory data) private pure returns (address) { // todo: move to a preprocessor
        require(data.length == 20, "Invalid address format");
        address addr;
        assembly {
            addr := mload(add(data, 20))
        }
        return addr;
    }
}