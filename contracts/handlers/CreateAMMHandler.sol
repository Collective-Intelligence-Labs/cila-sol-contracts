pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../proto/command.proto.sol";
import "../AMMAggregate.sol";
import "../EventStore.sol";
import "../AMMStateSpooler.sol";
import "../Utils.sol";


contract TransferNFTHandler is Ownable {
    
    EventStore public eventstore;

    constructor(address eventstore_) {
        eventstore = EventStore(eventstore_);
    }

    function handle(bytes memory payload, string memory aggregateId) external
    {
          (bool success, , CreateAMMPayload memory cmd) = CreateAMMPayloadCodec.decode(0, payload, uint64(payload.length));
          AMMState state = new AMMState();
          DomainEvent[] memory evnts = eventstore.pull(aggregateId, 0, 1000000);
          for (uint i = 0; i < evnts.length; i++) {
                DomainEvent memory evnt = evnts[i];
                AMMStateSpooler.spool(state, evnt.evnt_type, evnt.evnt_payload);
          }
          AMMAggregate aggregate = new AMMAggregate(state, evnts.length);

          aggregate.transfer(Utils.bytesToBytes32(cmd.hash,0), cmd.to);

          DomainEvent[] memory changes = new DomainEvent[](aggregate.getChangesLength());

        for (uint i = 0; i < aggregate.getChangesLength(); i++) {
            DomainEvent memory evnt = aggregate.getChange(i);
            eventstore.append(aggregate.id(), evnt);
            changes[i] = evnt;
        }
    }
}