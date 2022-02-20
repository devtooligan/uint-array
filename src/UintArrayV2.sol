// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import './ArrayInterface.sol';

/// @notice dynamic uint8[] maximum length 31
/// @dev    using a uint256 and bitshift operations -- array length stored in first byte
/// @author @devtooligan
contract UintArrayV2 is ArrayInterface {

    /* Storage
    *********************************************************************************************/

    /// @dev initial value - the first byte stores the length which is offset by 0x10
    /// without the offset, extra handling would have to be added for 0 length
    uint256 public uintArr = 0x1000000000000000000000000000000000000000000000000000000000000000;

    /* Main functions
    *********************************************************************************************/

    /// @dev iterates through the array elements and returns an actual uint8[] array
    function getArr() public view returns (uint8[] memory arr) {
        unchecked {
            uint256 length_ = length();
            arr = new uint8[](length_);
            uint256 uintArr_ = uintArr;
            for (
                uint256 index;
                index < length_;
                index = _incrementCounter(index)
            ) {
                arr[index] = _val(index + 1, uintArr_);
            }
        }
    }

    /// @dev the length is stored in the first byte of uintArr
    /// it is offset by 0x10 to intialize the uint
    /// @return length of array
    function length() public view returns (uint8) {
        uint256 uintArr_ = uintArr;
        return uint8((uintArr_ >> ((((32 - 1) - 0) * 2) << 2)) & 0xFF) - 0x10;
    }

    /// @dev retrieve a value at an index via bitshift operations
    /// @param index of element to return the value of
    /// @return value of the specified element
    function val(uint256 index) public view returns (uint8 value) {
        unchecked {
            uint256 length_ = length();
            require(index < length_, "outtarange");
            // adjust index +1 because first byte is length
            value = uint8(
                (uintArr >> ((((32 - 1) - (index + 1)) * 2) << 2)) & 0xFF
            );
        }
    }

    /// @notice maximium length 31 because first byte stores length
    /// @dev use arithmetic to update value (no iterating like in V1)
    /// @param value of new element added to the end of the array
    function push(uint8 value) public {
        unchecked {
            uint8 length_ = length();
            require(length_ < 31, "no mas");
            uint256 uintArr_ = uintArr;

            // calculate difference from adding one to length
            // length is stored in index0
            int256 diff = _changeDiff(0, 1, 0);

            // update with value at the new index.
            // new index == old length + 1 to account for the length stored in index0
            diff += _changeDiff(0, value, length_ + 1);

            if (diff < 0) {
                uintArr_ = uintArr_ - _abs(diff);
            } else {
                uintArr_ = uintArr_ + _abs(diff);
            }

            uintArr = uintArr_;
        }
    }

    /// @dev use arithmetic to update value
    /// @return value of the last element which is deleted
    function pop() public returns (uint8 value) {
        unchecked {
            uint8 length_ = length();
            require(length_ != 0, "no can");
            uint256 uintArr_ = uintArr;

            // reduce length by 1
            int256 diff = _changeDiff(1, 0, 0);
            // last_position == length - 1 + 1 == length_
            value = _val(length_, uintArr_);
            diff += _changeDiff(value, 0, length_);
            if (diff < 0) {
                uintArr_ = uintArr_ - _abs(diff);
            } else {
                uintArr_ = uintArr_ + _abs(diff);
            }
            uintArr = uintArr_;
        }
    }

    function remove(uint256 index) public {
        uint8 popped = pop();
        set(index, popped);
    }

    function set(uint256 index, uint8 value) public {
        require(index < length(), "outbounds");
        unchecked {
            _set(index + 1, value); // adjust index by 1. first byte is length
        }
    }

    /* Utility fns
    *********************************************************************************************/

    /// @dev calcs the difference to update a value at an index.
    /// Example:  if the last index is 0x06, and the new value is 0x04, this would return -0x02;
    /// If it was same numbers but in second to last index, it would return -0x0200
    /// @param oldVal old value
    /// @param newVal new value
    /// @param index of element that will be changed
    function _changeDiff(
        uint8 oldVal,
        uint8 newVal,
        uint256 index
    ) private pure returns (int256) {
        int256 diff = int256(uint256(newVal)) - int256(uint256(oldVal));
        return diff << (256 - (8 * (1 + index)));
    }

    /// @dev delete element and replace it with a popped element
    /// @param index of element to remove
    function _incrementCounter(uint256 index) private pure returns (uint256) {
        unchecked {
            return index + 1;
        }
    }

    /// @param x value to determine absolute value
    /// @return absolute value of x
    function _abs(int256 x) private pure returns (uint256) {
        return uint256(x < 0 ? -x : x);
    }

    /* Optimized internal fns
    *********************************************************************************************/

    /// @dev not checked for out of bounds
    /// @param index of element to return the value of
    /// @return value of the specified element
    function _val(uint256 index) private view returns (uint8 value) {
        unchecked {
            value = uint8((uintArr >> ((((32 - 1) - index) * 2) << 2)) & 0xFF);
        }
    }

    /// @dev not checked for out of bounds
    /// @param index of element to return the value of
    /// @param uintArr_ passing this in avoids an SLOAD
    /// @return value of the specified element
    function _val(uint256 index, uint256 uintArr_) private pure returns (uint8 value) {
        unchecked {
            value = uint8((uintArr_ >> ((((32 - 1) - index) * 2) << 2)) & 0xFF);
        }
    }

    /// @dev not checked for out of bounds, not adjusted +1 for length byte
    /// @param index of element to return the value of
    function _set(uint256 index, uint8 value) private {
        uint256 uintArr_ = uintArr;
        unchecked {
            int256 diff = _changeDiff(_val(index, uintArr_), value, index);
            if (diff > 0) {
                uintArr = uintArr_ + uint256(diff);
            } else {
                uintArr = uintArr_ - _abs(diff);
            }
        }
    }
}
