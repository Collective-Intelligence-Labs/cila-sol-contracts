pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "./proto/event.proto.sol";
import "./NFTsState.sol";

library NFTStateSpooler {

    function spool(NFTsState state, DomainEventType evntType, bytes memory payload) external returns (NFTsState)
    {
        if (evntType == DomainEventType.NFT_MINTED)
        {
            (bool success, , NFTMintedPayload memory evnt) = NFTMintedPayloadCodec.decode(0, payload, uint64(payload.length));
            state.on(evnt);
        }
        if (evntType == DomainEventType.NFT_TRANSFERED)
        {
            (bool success, , NFTTransferedPayload memory evnt) = NFTTransferedPayloadCodec.decode(0, payload, uint64(payload.length));
            state.on(evnt);
        }
        return state;
    }
}