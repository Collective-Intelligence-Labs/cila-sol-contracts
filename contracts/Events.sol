// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct DomainEvent {
    uint256 idx;
    DomainEventType t;
    bytes payload;
}

enum DomainEventType {
    NFTMinted,
    NFTTransfered
}

struct NFTMintedPayload {
    bytes32 hash;
    address owner;
}

struct NFTTransferedPayload {
    bytes32 hash;
    address from;
    address to;
}