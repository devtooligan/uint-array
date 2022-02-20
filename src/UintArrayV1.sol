// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import './ArrayInterface.sol';

/// @notice dynamic uint8[] array -- maximum length 32
/// @dev    using a uint256 and bitshift operations -- length stored in state
/// @author @devtooligan
contract UintArrayV1 is ArrayInterface {

    /* Storage
    *********************************************************************************************/

    uint256 public uintArr;
    uint8 public length; // length stored in state

    /* Main functions
    *********************************************************************************************/

    /// @dev iterates through the array elements and returns an actual uint8[] array
    function getArr() public view returns (uint8[] memory arr) {
        unchecked {
            uint8 length_ = length;
            arr = new uint8[](length_);
            uint256 uintArr_ = uintArr;
            for (
                uint256 index;
                index < length_;
                index = _incrementCounter(index)
            ) {
                arr[index] = _val(index + 1, length_, uintArr_);
            }
        }
    }

    /// @dev retrieve a value at an index via bitshift operations
    /// @param index of element to return the value of
    /// @return value of the specified element
    function val(uint256 index) public view returns (uint8 value) {
        unchecked {
            uint256 length_ = length;
            require(index < length_, "outtarange");
            value = uint8(
                (uintArr >> ((((length_ - 1) - index) * 2) << 2)) & 0xFF
            );
        }
    }

    /// @dev maximium length 32
    /// @param value of new element added to the end of the array
    function push(uint8 value) public {
        unchecked {
            uint8 length_ = length;
            require(length_ < 32, "no mas");
            length = length_ + 1;  // update length in state
            uintArr *= 256;
            set(length_, value); // update the "array" with new value
        }
    }

    /// @return value of popped element
    function pop() public returns (uint8 value) {
        unchecked {
            uint256 length_ = length;
            require(length_ != 0, "no can");
            value = _val(length_ - 1, length_);
            set(length_ - 1, 0);
            length = length - 1;
        }
    }

    /// @dev delete element and replace it with a popped element
    /// @param index of element to remove
    function remove(uint256 index) public {
        uint8 popped = pop();
        set(index, popped);
    }

    /// @param index to update
    /// @param value is the new value being set
    /// @dev iterate through array elements to reconstruct the array uint value
    /// NOTE: this is handled more efficiently in V2
    function set(uint256 index, uint8 value) public {
        uint256 length_ = length;
        uint256 newUintArr;
        unchecked {
            for (uint256 pointer; pointer < length_; ++pointer) {
                uint256 newVal;
                if (pointer == index) {
                    newVal = value;
                } else {
                    newVal = _val(pointer, length_);
                }
                uint256 reverseIndex = length_ - 1 - pointer;
                newUintArr += uint256(uint256(newVal) << (reverseIndex * 8));
            }
            uintArr = newUintArr;
        }
    }

    /* Private utility fns
    *********************************************************************************************/

    /// @notice unchecked increment counter to save gas in for loops
    /// @dev compiler should inline this
    function _incrementCounter(uint256 index) private pure returns (uint256) {
        unchecked {
            return index + 1;
        }
    }

    /* Optimized internal fns
    *********************************************************************************************/

    /// @dev not checked for out of bounds -- used with set()
    /// @param index of element to return the value of
    /// @param length_ passing this in avoids an SLOAD
    /// @return value of the specified element
    function _val(uint256 index, uint256 length_)
        private
        view
        returns (uint8 value)
    {
        unchecked {
            value =
                uint8(uintArr >> ((((length_ - 1) - index) * 2) << 2)) &
                0xFF;
        }
    }

    /// @dev not checked for out of bounds -- used with getArr()
    /// @param index of element to return the value of
    /// @param length_ passing this in avoids an SLOAD
    /// @param uintArr_ passing this in avoids an SLOAD
    /// @return value of the specified element
    function _val(uint256 index, uint8 length_, uint256 uintArr_)
        private
        pure
        returns (uint8 value)
    {
        unchecked {
            value =
                uint8(uintArr_ >> ((((length_ - 1) - index) * 2) << 2)) &
                0xFF;
        }
    }

}
