// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/** 
 * @title Dispatcher
 * @dev Entrypoint for transaction
 */
contract Dispatcher is Ownable {

    mapping (address => bool) public Routers;

    uint256 public dispatchedCount;


    modifier onlyRouter {
        require(Routers[tx.origin], "Unauthorized: transaction sender must be an authorized Router");
        _;
    }

    function addRouter(address router) public onlyOwner {
        Routers[router] = true;
    }

    function removeRouter(address router) public onlyOwner {
        delete Routers[router];
    }

    function dispatch(bytes memory opBytes) public onlyRouter returns(string memory result) {
        dispatchedCount++;
        result = string.concat("OK: ", string(abi.encodePacked(opBytes)));
    }

}