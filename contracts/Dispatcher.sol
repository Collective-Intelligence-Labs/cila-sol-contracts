// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Aggregate.sol";
import "./AggregateRepository.sol";
import "./Commands.sol";

/** 
 * @title Dispatcher
 * @dev Entrypoint for transaction
 */
contract Dispatcher is Ownable {

    mapping (address => bool) public routers;
    AggregateRepository public repository;

    constructor(address relay) {
        repository = new AggregateRepository(relay);
    }

    modifier onlyRouter {
        require(routers[msg.sender], "Unauthorized: transaction sender must be an authorized Router");
        _;
    }

    function addRouter(address router) public onlyOwner {
        routers[router] = true;
    }

    function removeRouter(address router) public onlyOwner {
        delete routers[router];
    }

    function dispatch(bytes memory opBytes) public onlyRouter {
        // todo: Desirialize opBytes to commands
        
        MintNFTPayload memory cp1;
        cp1.hash = keccak256("Super cool NFT");
        cp1.owner = msg.sender;

        Command memory cmd1;
        cmd1.t = CommandType.MintNFT;
        cmd1.payload = abi.encode(cp1);


        TransferNFTPayload memory cp2;
        cp2.hash = keccak256("Super cool NFT");
        cp2.to = address(0x847E705058DF6CfFbB718c39664A93a93804e943);

        Command memory cmd2;
        cmd2.t = CommandType.TransferNFT;
        cmd2.payload = abi.encode(cp2);

        address aggregateId = address(repository.ag());
        Aggregate aggregate = repository.get(aggregateId);

        aggregate.handle(cmd1);
        aggregate.handle(cmd2);

        repository.save(aggregate);
    }

}