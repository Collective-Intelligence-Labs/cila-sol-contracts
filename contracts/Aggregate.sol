// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./AggregateState.sol";
import "./proto/event.proto.sol";
import "./proto/command.proto.sol";


abstract contract Aggregate is Ownable {

    string public id;
    DomainEvent[] changes;
    uint256 version;

    function getChangesLength() external view returns (uint256)  {
        return version;
    }

    function getChange(uint i) external view returns (DomainEvent memory)  {
        return changes[i];
    }
}