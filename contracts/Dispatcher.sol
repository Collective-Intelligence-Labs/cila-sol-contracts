// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Aggregate.sol";
import "./AggregateRepository.sol";
import "./proto/operation.proto.sol";
import "./proto/command.proto.sol";


/** 
 * @title Dispatcher
 * @dev Entrypoint for router transaction
 */
contract Dispatcher is Ownable {

    mapping (address => bool) public routers;
    AggregateRepository public repository;
    bool locked;


    constructor(address relay) {
        repository = new AggregateRepository(relay);
    }


    event OmnichainEvent(uint64 indexed _idx, DomainEventType indexed _type, bytes _payload);


    modifier onlyRouter {
        require(routers[msg.sender], "Unauthorized: transaction sender must be an authorized Router");
        _;
    }


    modifier noReentrancy() {
        require(!locked, "Reentrancy call is not allowed");
        locked = true;
        _;
        locked = false;
    }


    function addRouter(address router) public onlyOwner {
        routers[router] = true;
    }


    function removeRouter(address router) public onlyOwner {
        delete routers[router];
    }


    function dispatch(bytes memory opBytes) public onlyRouter noReentrancy {

        (bool success, , Operation memory operation) = OperationCodec.decode(0, opBytes, uint64(opBytes.length));
        require(success, "Operation deserialization failed");

        Aggregate aggregate = repository.get();

        for (uint i = 0; i < operation.commands.length; i++) {
            // todo: check cmd author signature
            aggregate.handle(operation.commands[i]);
        }

        DomainEvent[] memory recentChanges = repository.save(aggregate);
        for (uint i = 0; i < recentChanges.length; i++) {
            DomainEvent memory recentChange = recentChanges[i];
            emit OmnichainEvent(recentChange.evnt_idx, recentChange.evnt_type, DomainEventCodec.encode(recentChange));
        }
    }

}