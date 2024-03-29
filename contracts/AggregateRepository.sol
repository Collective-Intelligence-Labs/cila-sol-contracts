// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EventStore.sol";
import "./Aggregate.sol";
import "./NFTsAggregate.sol";
import "./proto/event.proto.sol";
import "./proto/command.proto.sol";


contract AggregateRepository is Ownable {

    EventStore public eventstore;
    address public dispatcher;

    mapping(string => address) public aggregates;
    
    uint constant BATCH_LIMIT = 1000; // for demo purposes only

    constructor(address eventstore_) {
        eventstore = EventStore(eventstore_);
    }

    modifier onlyDispatcher {
        require(msg.sender == dispatcher, "Unauthorized: transaction sender must be an authorized Dispatcher");
        _;
    }

    function setDispatcher(address dispatcher_) public onlyOwner {
        dispatcher = dispatcher_;
    }

    function addAggregate(string memory id) public onlyOwner { // for demo purposes only
        aggregates[id] = address(new NFTsAggregate(id));
    }

    function get(string memory aggregateId) external onlyDispatcher returns (Aggregate) {
        require(aggregates[aggregateId] != address(0), "No aggregate found for provided id");

        DomainEvent[] memory evnts = eventstore.pull(aggregateId, 0, BATCH_LIMIT);
        Aggregate(aggregates[aggregateId]).setup(evnts);

        return Aggregate(aggregates[aggregateId]);
    }

    function save(Aggregate aggregate) external onlyDispatcher returns (DomainEvent[] memory) {
        DomainEvent[] memory changes = new DomainEvent[](aggregate.getChangesLength());

        for (uint i = 0; i < aggregate.getChangesLength(); i++) {
            DomainEvent memory evnt = aggregate.getChange(i);
            eventstore.append(aggregate.id(), evnt);
            changes[i] = evnt;
        }

        aggregate.reset();

        return changes;
    }

}