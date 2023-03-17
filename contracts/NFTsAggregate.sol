// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Aggregate.sol";
import "./NFTsState.sol";
import "./proto/command.proto.sol";

import "./Events.sol";

contract NFTsAggregate is Aggregate {

    constructor() {
        state = new NFTsState();
    }

    function handleCommand(Command memory cmd) internal override { 

        if (cmd.cmd_type == CommandType.MINT_NFT) {
            (bool success, uint64 pos, MintNFTPayload memory payload) = MintNFTPayloadCodec.decode(0, cmd.cmd_payload, uint64(cmd.cmd_payload.length));
            require(success, "MintNFTPayload deserialization failed");

            mint(payload);
        } 
        
        if (cmd.cmd_type == CommandType.TRANSFER_NFT) {
            (bool success, uint64 pos, TransferNFTPayload memory payload) = TransferNFTPayloadCodec.decode(0, cmd.cmd_payload, uint64(cmd.cmd_payload.length));
            require(success, "TransferNFTPayload deserialization failed");
            
            transfer(payload);
        }
    }

    function mint(MintNFTPayload memory payload) private {
        NFTsState s = NFTsState(address(state));

        bytes32 hash = bytes32(payload.hash);
        address owner = bytesToAddress(payload.owner);
        require(s.items(hash) == address(0), "NFT with such hash is already minted");

        NFTMintedPayload memory ep; 
        ep.hash = hash;
        ep.owner = owner;

        DomainEvent memory evnt;
        evnt.idx = eventsCount;
        evnt.t = DomainEventType.NFTMinted;
        evnt.payload = abi.encode(ep);

        applyEvent(evnt);
    }

    function transfer(TransferNFTPayload memory payload) private {
        NFTsState s = NFTsState(address(state));
        
        bytes32 hash = bytes32(payload.hash);
        address to = bytesToAddress(payload.to);
        require(s.items(hash) != to, "NFT can not be transferred to its current owner");

        NFTTransferedPayload memory ep;
        ep.hash = hash;
        ep.from = s.items(hash);
        ep.to = to;
        
        DomainEvent memory evnt;
        evnt.idx = eventsCount;
        evnt.t = DomainEventType.NFTTransfered;
        evnt.payload = abi.encode(ep);

        applyEvent(evnt);
    }

    function bytesToAddress(bytes memory data) private pure returns (address) { // temp
        require(data.length == 20, "Invalid address length");
        address addr;
        assembly {
            addr := mload(add(data, 20))
        }
        return addr;
    }
}