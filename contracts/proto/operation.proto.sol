// File automatically generated by protoc-gen-sol v0.2.0
// SPDX-License-Identifier: CC0
pragma solidity >=0.8.0 <9.0.0;
pragma experimental ABIEncoderV2;

import "@lazyledger/protobuf3-solidity-lib/contracts/ProtobufLib.sol";
import "./command.proto.sol";

struct Operation {
    bytes router_id;
    Command[] commands;
}

library OperationCodec {
    function decode(uint64 initial_pos, bytes memory buf, uint64 len) internal pure returns (bool, uint64, Operation memory) {
        // Message instance
        Operation memory instance;
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

    function decode_field(uint64 initial_pos, bytes memory buf, uint64 len, uint64 field_number, Operation memory instance) internal pure returns (bool, uint64) {
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

    // Operation.router_id
    function decode_1(uint64 pos, bytes memory buf, Operation memory instance) internal pure returns (bool, uint64) {
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

        instance.router_id = new bytes(len);
        for (uint64 i = 0; i < len; i++) {
            instance.router_id[i] = buf[pos + i];
        }

        pos = pos + len;

        return (true, pos);
    }

    // Operation.commands
    function decode_2(uint64 pos, bytes memory buf, Operation memory instance) internal pure returns (bool, uint64) {
        bool success;

        uint64 initial_pos = pos;

        // Do one pass to count the number of elements
        uint64 cnt = 0;
        while (pos < buf.length) {
            uint64 len;
            (success, pos, len) = ProtobufLib.decode_embedded_message(pos, buf);
            if (!success) {
                return (false, pos);
            }

            // Sanity checks
            if (pos + len < pos) {
                return (false, pos);
            }

            pos += len;
            cnt += 1;

            if (pos >= buf.length) {
                break;
            }

            // Decode next key
            uint64 field_number;
            ProtobufLib.WireType wire_type;
            (success, pos, field_number, wire_type) = ProtobufLib.decode_key(pos, buf);
            if (!success) {
                return (false, pos);
            }

            // Check if the field number is different
            if (field_number != 2) {
                break;
            }
        }

        // Allocated memory
        instance.commands = new Command[](cnt);

        // Now actually parse the elements
        pos = initial_pos;
        for (uint64 i = 0; i < cnt; i++) {
            uint64 len;
            (success, pos, len) = ProtobufLib.decode_embedded_message(pos, buf);
            if (!success) {
                return (false, pos);
            }

            initial_pos = pos;

            Command memory nestedInstance;
            (success, pos, nestedInstance) = CommandCodec.decode(pos, buf, len);
            if (!success) {
                return (false, pos);
            }

            instance.commands[i] = nestedInstance;

            // Skip over next key, reuse len
            if (i < cnt - 1) {
                (success, pos, len) = ProtobufLib.decode_uint64(pos, buf);
                if (!success) {
                    return (false, pos);
                }
            }
        }

        return (true, pos);
    }

}

