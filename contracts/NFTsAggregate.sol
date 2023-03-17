// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Aggregate.sol";
import "./NFTsState.sol";
import "./Commands.sol";
import "./Events.sol";

contract NFTsAggregate is Aggregate {

    constructor() {
        state = new NFTsState();
    }

    function handleCommand(Command memory cmd) internal override { 
        if (cmd.t == CommandType.MintNFT) {
            mint(cmd);
        } else if (cmd.t == CommandType.TransferNFT) {
            transfer(cmd);
        }
    }

    function mint(Command memory cmd) private {
        MintNFTPayload memory cp = abi.decode(cmd.payload, (MintNFTPayload));
        NFTsState s = NFTsState(address(state));
        require(s.items(cp.hash) == address(0), "NFT with such hash is already minted");

        NFTMintedPayload memory ep; 
        ep.hash = cp.hash;
        ep.owner = cp.owner;

        DomainEvent memory evnt;
        evnt.idx = eventsCount;
        evnt.t = DomainEventType.NFTMinted;
        evnt.payload = abi.encode(ep);

        applyEvent(evnt);
    }

    function transfer(Command memory cmd) private {
        TransferNFTPayload memory cp = abi.decode(cmd.payload, (TransferNFTPayload));
        NFTsState s = NFTsState(address(state));
        require(s.items(cp.hash) != cp.to, "NFT can not be transferred to its current owner");

        NFTTransferedPayload memory ep;
        ep.hash = cp.hash;
        ep.from = s.items(cp.hash);
        ep.to = cp.to;
        
        DomainEvent memory evnt;
        evnt.idx = eventsCount;
        evnt.t = DomainEventType.NFTTransfered;
        evnt.payload = abi.encode(ep);

        applyEvent(evnt);
    }

}