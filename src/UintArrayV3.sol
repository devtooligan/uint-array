// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

/// @notice fixed uint8[32] array
/// @dev    using a uint256 and bitshift operations
/// @author @devtooligan
contract UintArrayV3 {

    /* Storage
    *********************************************************************************************/

    uint256 public uintArr;

    /* Main functions
    *********************************************************************************************/

    /// @dev iterates through the array elements and returns an actual uint8[] array
    function getArr() public view returns (uint8[] memory arr) {
        unchecked {
            arr = new uint8[](32);
            uint256 uintArr_ = uintArr;
            for (
                uint256 index;
                index < 32;
                index = _incrementCounter(index)
            ) {
                arr[index] = _val(index, uintArr_);
            }
        }
    }

    /// @return length of array
    function length() public pure returns (uint8) {
        return 32;
    }

    /// @dev retrieve a value at an index via bitshift operations
    /// @param index of element to return the value of
    /// @return value of the specified element
    function val(uint256 index) public view returns (uint8 value) {
        unchecked {
            require(index < 32, "outtarange");
            value = uint8(
                (uintArr >> (((31 - (index)) * 2) << 2)) & 0xFF
            );
        }
    }

    /// @param index to update
    /// @param value is the new value being set
    /// @dev iterate through array elements to reconstruct the array uint value
    function set(uint256 index, uint8 value) public {
        unchecked {
            require(index < length(), "outbounds");
            uint256 uintArr_ = uintArr;
            int256 diff = _changeDiff(_val(index, uintArr_), value, index);
            if (diff > 0) {
                uintArr = uintArr_ + uint256(diff);
            } else {
                uintArr = uintArr_ - _abs(diff);
            }
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
    /// @param uintArr_ passing this in avoids an SLOAD
    /// @return value of the specified element
    function _val(uint256 index, uint256 uintArr_) private pure returns (uint8 value) {
        unchecked {
            value = uint8((uintArr_ >> ((((32 - 1) - index) * 2) << 2)) & 0xFF);
        }
    }

}
