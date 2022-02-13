// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

interface ITinyArray {
    function length() external view returns (uint256);
    function val(uint256 index) external view returns (uint256);
    function set(uint256 targetIdx, uint8 newVal) external returns(uint256 newTinyArr);
    function push(uint8 value) external;
    function pop() external returns (uint8 value);
    function remove(uint256 index) external;
    function getArr() external returns(uint256);
}


/// @dev dynamic uint8[] maximum length 32
/// @author @devtooligan
contract TinyArray is ITinyArray {
    uint256 public tinyArr;
    uint256 public length;

    function getArr() public view returns (uint256) {
        return tinyArr;
    }

    function val(uint256 index) public view returns (uint256 value) {
        unchecked {
            uint256 length_ = length;
            require(index < length_, "outtarange");
            value = uint256((tinyArr >> ((((length_ - 1) - index) * 2 ) << 2)) & 0xFF);

        }
    }

    /// @dev this one not checked for out of bounds -- used with set()
    function _val(uint256 index, uint256 length_) private view returns (uint8 value) {
        unchecked {
            value = uint8(tinyArr >> ((((length_ - 1) - index) * 2) << 2)) & 0xFF;
        }
    }

    function set(uint256 targetIdx, uint8 newVal) public returns(uint256 newTinyArr) {
        uint256 length_ = length;
        unchecked {
            for (uint256 pointer; pointer < length_; ++pointer) {
                uint256 value;
                if (pointer == targetIdx) {
                    value = newVal;
                } else {
                    value = _val(pointer, length_);
                }
                uint256 reverseIndex = length_ - 1 - pointer;
                newTinyArr += uint256(uint256(value) << (reverseIndex * 8));
            }
            tinyArr = newTinyArr;
        }
    }

        function push(uint8 value) public {
        unchecked {
            uint256 length_ = length;
            require(length_ < 32, "no mas");
            length = length_ + 1;
            tinyArr *= 256;
            set(length_, value);
        }
    }

    /// @return value The value of the last element which is deleted
    function pop() public returns (uint8 value) {
        unchecked {
            uint256 length_ = length;
            value = _val(length_ - 1, length_);
            set(length_ - 1, 0);
            length = length - 1;
        }
    }

    function remove(uint256 index) public {
        uint8 popped = pop();
        set(index, popped);
    }
}
