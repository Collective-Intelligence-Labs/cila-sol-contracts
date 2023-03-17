pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EventStore.sol";
import "./Aggregate.sol";
import "./NFTsAggregate.sol";
import "./Commands.sol";


contract AggregateRepository is Ownable {

    EventStore public eventstore;
    Aggregate public ag;
    
    uint constant BATCH_LIMIT = 1000; // for demo purposes only

    constructor(address relay) {
        eventstore = new EventStore(relay);
        ag = new NFTsAggregate(msg.sender); // for demo purposes only
    }

    function get(address aggregateId) external onlyOwner returns (Aggregate aggregate) {
        require(address(ag) == aggregateId, "Only one aggregate is supported at the moment");

        DomainEvent[] memory evnts = eventstore.get(aggregateId, 0, BATCH_LIMIT);
        ag.replay(evnts);

        return ag;
    }

    function save(Aggregate aggregate) external onlyOwner {
        require(address(aggregate) == address(ag), "Only one aggregate is supported at the moment");

        for (uint i = 0; i < aggregate.getChangesLength(); i++) {
            DomainEvent memory evnt = aggregate.getChange(i);
            eventstore.append(address(aggregate), evnt);
            // todo: Publish event
        }
    }
}