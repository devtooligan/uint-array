// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

interface INormalArray {
    function getArr() external view returns(uint8[] memory);
    function val(uint256 index) external view returns (uint256);
    function push(uint8 value) external;
    function pop() external returns (uint8 value);
    function length() external view returns (uint256);
    function set(uint256 targetIdx, uint8 newVal) external;
    function remove(uint256 index) external;
}


/// @author Adapted by @devtooligan from https://solidity-by-example.org/array/
contract NormalArray is INormalArray {
    uint8[] public arr;

    function getArr() public view returns(uint8[] memory) {
        return arr;
    }
    function val(uint256 index) public view returns(uint256) {
        return arr[index];
    }

    function push(uint8 value) public {
        arr.push(value);
    }
    function pop() public returns(uint8 value) {
        value = arr[arr.length];
        arr.pop();
    }

    function length() public view returns (uint256) {
        return arr.length;
    }

    function remove(uint256 index) public {
        arr[index] = pop();
    }
    function set(uint256 index, uint8 value) public {
        require(value != 0xff, 'no can');
        arr[index] = value;
    }

}
