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
    Aggregate public aggregate;
    address public dispatcher;
    
    uint constant BATCH_LIMIT = 1000; // for demo purposes only

    constructor(address eventstore_) {
        eventstore = EventStore(eventstore_);
        aggregate = new NFTsAggregate(); // for demo purposes only
    }

    modifier onlyDispatcher {
        require(msg.sender == dispatcher, "Unauthorized: transaction sender must be an authorized Dispatcher");
        _;
    }

    function setDispatcher(address dispatcher_) public onlyOwner {
        dispatcher = dispatcher_;
    }

    function get(/* address aggregateId */) external onlyDispatcher returns (Aggregate) {

        DomainEvent[] memory evnts = eventstore.pull(address(aggregate), 0, BATCH_LIMIT);
        aggregate.setup(evnts);

        return aggregate;
    }

    function save(Aggregate ag) external onlyDispatcher returns (DomainEvent[] memory) {

        DomainEvent[] memory changes = new DomainEvent[](ag.getChangesLength());

        for (uint i = 0; i < ag.getChangesLength(); i++) {
            DomainEvent memory evnt = ag.getChange(i);
            eventstore.append(address(ag), evnt);
            changes[i] = evnt;
        }

        ag.reset();

        return changes;
    }

}