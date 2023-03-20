// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./proto/event.proto.sol";


contract EventStore {

    mapping (address => DomainEvent[]) streams;
    address relay;

    constructor(address relay_) {
        relay = relay_;
    }

    modifier onlyRelay {
        require(msg.sender == relay, "Unauthorized: transaction sender must be an authorized Router");
        _;
    }


    function get(address aggregateId, uint idx) public view returns (DomainEvent memory) {
        require(idx < streams[aggregateId].length, "Index out of bounds");
        DomainEvent memory evnt = streams[aggregateId][idx];
        return evnt;
    }


    function getBytes(address aggregateId, uint idx) public view returns (bytes memory) {
        DomainEvent memory evnt = get(aggregateId, idx);
        bytes memory ev = DomainEventCodec.encode(evnt);
        return ev;
    }


    function pull(address aggregateId, uint startIndex, uint limit) public view returns (DomainEvent[] memory) {

        uint length = streams[aggregateId].length;
        if (startIndex >= length) {
            return new DomainEvent[](0);
        }

        uint endIndex = startIndex + limit;
        if (endIndex > length) {
            endIndex = length;
        }

        DomainEvent[] memory events = new DomainEvent[](endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            events[i - startIndex] = streams[aggregateId][i];
        }

        return events;
    }


    function pullBytes(address aggregateId, uint startIndex, uint limit) external view returns (bytes[] memory) {
        DomainEvent[] memory events = pull(aggregateId, startIndex, limit);
        bytes[] memory list = new bytes[](events.length);

        for (uint i = 0; i < events.length; i++) {
            list[i] = DomainEventCodec.encode(events[i]);
        }

        return list;
    }


    function pushBytes(address aggregateId, uint startIndex, bytes[] memory evnts) external onlyRelay {
        DomainEvent[] memory list = new DomainEvent[](evnts.length);
        
        for (uint i = 0; i < evnts.length; i++) {
            (bool success, , DomainEvent memory evnt) = DomainEventCodec.decode(0, evnts[i], uint64(evnts[i].length));
            require(success, "Event deserialization failed");
            list[i] = evnt;
        }

        push(aggregateId, startIndex, list);
    }

    function push(address aggregateId, uint startIndex, DomainEvent[] memory evnts) public onlyRelay {
        require(startIndex <= streams[aggregateId].length - 1, "Slice out of bounds");
        removeRange(aggregateId, startIndex);
        addRange(aggregateId, evnts);
    }


    function append(address aggregateId, DomainEvent memory evnt) external { // todo: add repository authorization
        add(aggregateId, evnt);
    }


    function add(address aggregateId, DomainEvent memory evnt) private returns(uint eventIdx) {
        streams[aggregateId].push(evnt);
        return streams[aggregateId].length - 1;
    }


    function addRange(address aggregateId, DomainEvent[] memory evnts) private returns(uint eventIdx) {
        for (uint i = 0; i < evnts.length; i++) {
            streams[aggregateId].push(evnts[i]);
        }

        return streams[aggregateId].length - 1;
    }


    function remove(address aggregateId, uint idx) private {
        require(idx < streams[aggregateId].length, "Index out of bounds");

        for (uint i = idx; i < streams[aggregateId].length - 1; i++) {
            streams[aggregateId][i] = streams[aggregateId][i+1];
        }
        
        streams[aggregateId].pop();
    }


    function removeRange(address aggregateId, uint startIndex) private {
        require(startIndex < streams[aggregateId].length, "Index out of bounds");

        uint len = streams[aggregateId].length - startIndex;
        for (uint i = 0; i < len; i++) {
            streams[aggregateId].pop();
        }
    }

}