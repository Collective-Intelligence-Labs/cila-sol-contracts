// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./AggregateState.sol";
import "./Events.sol";
import "./Commands.sol";

abstract contract Aggregate is Ownable {

    AggregateState state;
    DomainEvent[] changes;
    bool isReady;
    uint256 eventsCount;


    function handle(Command memory cmd) external {
        require(isReady, "Aggregate is not setup");
        handleCommand(cmd);
    }

    function handleCommand(Command memory cmd) internal virtual;

    function applyEvent(DomainEvent memory evnt) internal {
        state.spool(evnt);
        eventsCount++;
        changes.push(evnt);
    }

    function getChangesLength() external view returns (uint256)  {
        return changes.length;
    }

    function getChange(uint i) external view returns (DomainEvent memory)  {
        return changes[i];
    }

    function setup(DomainEvent[] memory evnts) external onlyOwner {
        for (uint i = 0; i < evnts.length; i++) {
            state.spool(evnts[i]);
            eventsCount++;
        }
        isReady = true;
    }

    function reset() external onlyOwner {
        state.reset();
        for (uint i = 0; i < changes.length; i++) {
            delete changes[i];
        }
        isReady = false;
    }

}