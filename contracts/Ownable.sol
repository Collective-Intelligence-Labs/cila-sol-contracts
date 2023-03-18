// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // todo: move to a separate util contract after init code size optimizations
    function bytesToAddress(bytes memory data) internal pure returns (address) { // todo: move to a preprocessor
        require(data.length == 20, "Invalid address format");
        address addr;
        assembly {
            addr := mload(add(data, 20))
        }
        return addr;
    }
}