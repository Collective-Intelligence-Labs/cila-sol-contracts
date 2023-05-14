// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./AggregateState.sol";
import "./Utils.sol";
import "./proto/command.proto.sol";
import "./proto/event.proto.sol";


contract NFTsState {

    mapping (bytes32 => address) public nfts;
    bytes32[] public nftsIds;

    function on(NFTMintedPayload memory payload) public {
        bytes32 hash = bytes32(payload.hash);
        address owner = Utils.bytesToAddress(payload.owner);

        nfts[hash] = owner;
        nftsIds.push(hash);
    }

    function on(NFTTransferedPayload memory payload) public {
        bytes32 hash = bytes32(payload.hash);
        address to = Utils.bytesToAddress(payload.to);

        nfts[hash] = to;
    }
}