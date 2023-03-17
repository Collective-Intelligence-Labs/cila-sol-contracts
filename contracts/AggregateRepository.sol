pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EventStore.sol";
import "./Aggregate.sol";
import "./NFTsAggregate.sol";
import "./proto/event.proto.sol";
import "./proto/command.proto.sol";


contract AggregateRepository is Ownable {

    EventStore public eventstore;
    Aggregate public aggregate;
    
    uint constant BATCH_LIMIT = 1000; // for demo purposes only

    constructor(address relay) {
        eventstore = new EventStore(relay);
        aggregate = new NFTsAggregate(); // for demo purposes only
    }

    function get() external onlyOwner returns (Aggregate) {

        DomainEvent[] memory evnts = eventstore.pull(address(aggregate), 0, BATCH_LIMIT);
        aggregate.setup(evnts);

        return aggregate;
    }

    function save(Aggregate ag) external onlyOwner {

        for (uint i = 0; i < ag.getChangesLength(); i++) {
            DomainEvent memory evnt = ag.getChange(i);
            eventstore.append(address(ag), evnt);
            // todo: Publish event
        }

        ag.reset();
    }
}