// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Aggregate.sol";
import "./AggregateRepository.sol";
import "./proto/command.proto.sol";
import "./proto/operation.proto.sol";


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

        (bool success, uint64 pos, Operation memory operation) = OperationCodec.decode(0, opBytes, uint64(opBytes.length));
        require(success, "Operation deserialization failed");

        Aggregate aggregate = repository.get();

        for (uint i = 0; i < operation.commands.length; i++) {
            // todo: check cmd signature
            aggregate.handle(operation.commands[i]);
        }

        repository.save(aggregate);
    }

    function generateRandomAddress() private view returns (address) {
        uint256 randomUint = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, type(uint256).max)));
        bytes memory randomBytes = abi.encodePacked(randomUint);
        address randomAddress = address(uint160(uint256(keccak256(randomBytes))));
        return randomAddress;
    }

}