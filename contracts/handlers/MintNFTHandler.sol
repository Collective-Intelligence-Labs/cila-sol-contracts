pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../proto/command.proto.sol";
import "../NFTsAggregate.sol";
import "../NFTStateSpooler.sol";
import "../EventStore.sol";

contract MintNFTHandler is Ownable {

    EventStore public eventstore;

    constructor(address eventstore_) {
        eventstore = EventStore(eventstore_);
    }

    function handle(bytes memory payload, string memory aggregateId) external
    {
          (bool success, , MintNFTPayload memory cmd) = MintNFTPayloadCodec.decode(0, payload, uint64(payload.length));
          NFTsState state = new NFTsState();
          DomainEvent[] memory evnts = eventstore.pull(aggregateId, 0, 1000000);
          for (uint i = 0; i < evnts.length; i++) {
                DomainEvent memory evnt = evnts[i];
                NFTStateSpooler.spool(state, evnt.evnt_type, evnt.evnt_payload);
          }
          NFTsAggregate aggregate = new NFTsAggregate(state, evnts.length);
          aggregate.mint(cmd.hash, Utils.bytesToString(cmd.owner));

          DomainEvent[] memory changes = new DomainEvent[](aggregate.getChangesLength());

            for (uint i = 0; i < aggregate.getChangesLength(); i++) {
                DomainEvent memory evnt = aggregate.getChange(i);
                eventstore.append(aggregate.id(), evnt);
                changes[i] = evnt;
            }
    }
}