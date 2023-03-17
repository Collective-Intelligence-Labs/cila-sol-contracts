// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Aggregate.sol";
import "./AggregateRepository.sol";
import "./Commands.sol";

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
        // todo: Desirialize opBytes to commands
        
        MintNFTPayload memory cp1;
        cp1.hash = keccak256("Super cool NFT");
        cp1.owner = msg.sender;

        Command memory cmd1;
        cmd1.t = CommandType.MintNFT;
        cmd1.payload = abi.encode(cp1);


        TransferNFTPayload memory cp2;
        cp2.hash = keccak256("Super cool NFT");
        cp2.to = generateRandomAddress();

        Command memory cmd2;
        cmd2.t = CommandType.TransferNFT;
        cmd2.payload = abi.encode(cp2);

        Aggregate aggregate = repository.get();

        aggregate.handle(cmd1);
        aggregate.handle(cmd2);

        repository.save(aggregate);
    }

    function dispatch2(bytes memory opBytes) public onlyRouter returns(string memory result) {
        result = string.concat("OK: ", string(abi.encodePacked(opBytes)));
    }

    function generateRandomAddress() private view returns (address) {
        uint256 randomUint = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, type(uint256).max)));
        bytes memory randomBytes = abi.encodePacked(randomUint);
        address randomAddress = address(uint160(uint256(keccak256(randomBytes))));
        return randomAddress;
    }

}