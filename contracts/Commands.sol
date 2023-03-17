// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct Command {
    CommandType t;
    bytes payload;
}

enum CommandType {
    MintNFT,
    TransferNFT
}

struct MintNFTPayload {
    bytes32 hash;
    address owner;
}

struct TransferNFTPayload {
    bytes32 hash;
    address to;
}