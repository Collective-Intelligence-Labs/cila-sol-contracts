// File automatically generated by protoc-gen-sol v0.2.0
// SPDX-License-Identifier: CC0
pragma solidity >=0.8.0 <9.0.0;
pragma experimental ABIEncoderV2;

import "@lazyledger/protobuf3-solidity-lib/contracts/ProtobufLib.sol";

enum CommandType { UNSPECIFIED_COMMAND, MINT_NFT, TRANSFER_NFT }

struct Command {
    bytes aggregate_id;
    bytes cmd_signature;
    CommandType cmd_type;
    bytes cmd_payload;
}

library CommandCodec {
    function decode(uint64 initial_pos, bytes memory buf, uint64 len) internal pure returns (bool, uint64, Command memory) {
        // Message instance
        Command memory instance;
        // Previous field number
        uint64 previous_field_number = 0;
        // Current position in the buffer
        uint64 pos = initial_pos;

        // Sanity checks
        if (pos + len < pos) {
            return (false, pos, instance);
        }

        while (pos - initial_pos < len) {
            // Decode the key (field number and wire type)
            bool success;
            uint64 field_number;
            ProtobufLib.WireType wire_type;
            (success, pos, field_number, wire_type) = ProtobufLib.decode_key(pos, buf);
            if (!success) {
                return (false, pos, instance);
            }

            // Check that the field number is within bounds
            if (field_number > 4) {
                return (false, pos, instance);
            }

            // Check that the field number of monotonically increasing
            if (field_number <= previous_field_number) {
                return (false, pos, instance);
            }

            // Check that the wire type is correct
            success = check_key(field_number, wire_type);
            if (!success) {
                return (false, pos, instance);
            }

            // Actually decode the field
            (success, pos) = decode_field(pos, buf, len, field_number, instance);
            if (!success) {
                return (false, pos, instance);
            }

            previous_field_number = field_number;
        }

        // Decoding must have consumed len bytes
        if (pos != initial_pos + len) {
            return (false, pos, instance);
        }

        return (true, pos, instance);
    }

    function check_key(uint64 field_number, ProtobufLib.WireType wire_type) internal pure returns (bool) {
        if (field_number == 1) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        if (field_number == 2) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        if (field_number == 3) {
            return wire_type == ProtobufLib.WireType.Varint;
        }

        if (field_number == 4) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        return false;
    }

    function decode_field(uint64 initial_pos, bytes memory buf, uint64 len, uint64 field_number, Command memory instance) internal pure returns (bool, uint64) {
        uint64 pos = initial_pos;

        if (field_number == 1) {
            bool success;
            (success, pos) = decode_1(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        if (field_number == 2) {
            bool success;
            (success, pos) = decode_2(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        if (field_number == 3) {
            bool success;
            (success, pos) = decode_3(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        if (field_number == 4) {
            bool success;
            (success, pos) = decode_4(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        return (false, pos);
    }

    // Command.aggregate_id
    function decode_1(uint64 pos, bytes memory buf, Command memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.aggregate_id = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.aggregate_id[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

    // Command.cmd_signature
    function decode_2(uint64 pos, bytes memory buf, Command memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.cmd_signature = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.cmd_signature[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

    // Command.cmd_type
    function decode_3(uint64 pos, bytes memory buf, Command memory instance) internal pure returns (bool, uint64) {
        bool success;

        int32 v;
        (success, pos, v) = ProtobufLib.decode_enum(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (v == 0) {
            return (false, pos);
        }

        // Check that value is within enum range
        if (v < 0 || v > 2) {
            return (false, pos);
        }

        instance.cmd_type = CommandType(v);

        return (true, pos);
    }

    // Command.cmd_payload
    function decode_4(uint64 pos, bytes memory buf, Command memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.cmd_payload = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.cmd_payload[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

}

struct MintNFTPayload {
    bytes hash;
    bytes owner;
}

library MintNFTPayloadCodec {
    function decode(uint64 initial_pos, bytes memory buf, uint64 len) internal pure returns (bool, uint64, MintNFTPayload memory) {
        // Message instance
        MintNFTPayload memory instance;
        // Previous field number
        uint64 previous_field_number = 0;
        // Current position in the buffer
        uint64 pos = initial_pos;

        // Sanity checks
        if (pos + len < pos) {
            return (false, pos, instance);
        }

        while (pos - initial_pos < len) {
            // Decode the key (field number and wire type)
            bool success;
            uint64 field_number;
            ProtobufLib.WireType wire_type;
            (success, pos, field_number, wire_type) = ProtobufLib.decode_key(pos, buf);
            if (!success) {
                return (false, pos, instance);
            }

            // Check that the field number is within bounds
            if (field_number > 2) {
                return (false, pos, instance);
            }

            // Check that the field number of monotonically increasing
            if (field_number <= previous_field_number) {
                return (false, pos, instance);
            }

            // Check that the wire type is correct
            success = check_key(field_number, wire_type);
            if (!success) {
                return (false, pos, instance);
            }

            // Actually decode the field
            (success, pos) = decode_field(pos, buf, len, field_number, instance);
            if (!success) {
                return (false, pos, instance);
            }

            previous_field_number = field_number;
        }

        // Decoding must have consumed len bytes
        if (pos != initial_pos + len) {
            return (false, pos, instance);
        }

        return (true, pos, instance);
    }

    function check_key(uint64 field_number, ProtobufLib.WireType wire_type) internal pure returns (bool) {
        if (field_number == 1) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        if (field_number == 2) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        return false;
    }

    function decode_field(uint64 initial_pos, bytes memory buf, uint64 len, uint64 field_number, MintNFTPayload memory instance) internal pure returns (bool, uint64) {
        uint64 pos = initial_pos;

        if (field_number == 1) {
            bool success;
            (success, pos) = decode_1(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        if (field_number == 2) {
            bool success;
            (success, pos) = decode_2(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        return (false, pos);
    }

    // MintNFTPayload.hash
    function decode_1(uint64 pos, bytes memory buf, MintNFTPayload memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.hash = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.hash[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

    // MintNFTPayload.owner
    function decode_2(uint64 pos, bytes memory buf, MintNFTPayload memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.owner = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.owner[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

}

struct TransferNFTPayload {
    bytes hash;
    bytes to;
}

library TransferNFTPayloadCodec {
    function decode(uint64 initial_pos, bytes memory buf, uint64 len) internal pure returns (bool, uint64, TransferNFTPayload memory) {
        // Message instance
        TransferNFTPayload memory instance;
        // Previous field number
        uint64 previous_field_number = 0;
        // Current position in the buffer
        uint64 pos = initial_pos;

        // Sanity checks
        if (pos + len < pos) {
            return (false, pos, instance);
        }

        while (pos - initial_pos < len) {
            // Decode the key (field number and wire type)
            bool success;
            uint64 field_number;
            ProtobufLib.WireType wire_type;
            (success, pos, field_number, wire_type) = ProtobufLib.decode_key(pos, buf);
            if (!success) {
                return (false, pos, instance);
            }

            // Check that the field number is within bounds
            if (field_number > 2) {
                return (false, pos, instance);
            }

            // Check that the field number of monotonically increasing
            if (field_number <= previous_field_number) {
                return (false, pos, instance);
            }

            // Check that the wire type is correct
            success = check_key(field_number, wire_type);
            if (!success) {
                return (false, pos, instance);
            }

            // Actually decode the field
            (success, pos) = decode_field(pos, buf, len, field_number, instance);
            if (!success) {
                return (false, pos, instance);
            }

            previous_field_number = field_number;
        }

        // Decoding must have consumed len bytes
        if (pos != initial_pos + len) {
            return (false, pos, instance);
        }

        return (true, pos, instance);
    }

    function check_key(uint64 field_number, ProtobufLib.WireType wire_type) internal pure returns (bool) {
        if (field_number == 1) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        if (field_number == 2) {
            return wire_type == ProtobufLib.WireType.LengthDelimited;
        }

        return false;
    }

    function decode_field(uint64 initial_pos, bytes memory buf, uint64 len, uint64 field_number, TransferNFTPayload memory instance) internal pure returns (bool, uint64) {
        uint64 pos = initial_pos;

        if (field_number == 1) {
            bool success;
            (success, pos) = decode_1(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        if (field_number == 2) {
            bool success;
            (success, pos) = decode_2(pos, buf, instance);
            if (!success) {
                return (false, pos);
            }

            return (true, pos);
        }

        return (false, pos);
    }

    // TransferNFTPayload.hash
    function decode_1(uint64 pos, bytes memory buf, TransferNFTPayload memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.hash = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.hash[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

    // TransferNFTPayload.to
    function decode_2(uint64 pos, bytes memory buf, TransferNFTPayload memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 len;
        (success, pos, len) = ProtobufLib.decode_bytes(pos, buf);
        if (!success) {
            return (false, pos);
        }

        // Default value must be omitted
        if (len == 0) {
            return (false, pos);
        }

        instance.to = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.to[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

}

