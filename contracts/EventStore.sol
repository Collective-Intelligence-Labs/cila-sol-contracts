// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Events.sol";


contract EventStore is Ownable {

    mapping (address => DomainEvent[]) streams;
    address relay;

    constructor(address relay_) {
        relay = relay_;
    }

    modifier onlyRelay {
        require(msg.sender == relay, "Unauthorized: transaction sender must be an authorized Router");
        _;
    }


    function get(address aggregateId, uint startIndex, uint limit) public view returns (DomainEvent[] memory) {

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


    function append(address aggregateId, DomainEvent memory evnt) external onlyOwner {
        add(aggregateId, evnt);
    }


    function sync(address aggregateId, uint startIndex, DomainEvent[] memory evnts) external onlyRelay {
        require(startIndex <= streams[aggregateId].length - 1, "Slice out of bounds");
        removeRange(aggregateId, startIndex);
        addRange(aggregateId, evnts);
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


    function remove(address aggregateId, uint index) private {
        require(index < streams[aggregateId].length, "Index out of bounds");

        for (uint i = index; i < streams[aggregateId].length - 1; i++) {
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