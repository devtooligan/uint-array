// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import './ArrayInterface.sol';


/// @notice "normal" array implementation used as base case for comparison
/// @dev light wrapper around uint8[] array
/// @author Adapted by @devtooligan from https://solidity-by-example.org/array/
contract NormalArray is ArrayInterface {

    /* Storage
    *********************************************************************************************/

    uint8[] public arr;

    /* Main functions
    *********************************************************************************************/

    function getArr() public view returns(uint8[] memory) {
        return arr;
    }

    /// @return length of array
    function length() public view returns (uint8) {
        return uint8(arr.length);
    }

    /// @param index of element to return the value of
    /// @return value of the specified element
    function val(uint256 index) public view returns(uint8) {
        require(index < arr.length, "outtarange");
        return arr[index];
    }

    /// @param value of new element added to the end of the array
    function push(uint8 value) public {
        arr.push(value);
    }

    /// @return value of popped element
    function pop() public returns(uint8 value) {
        require(arr.length != 0, "no can");
        value = arr[arr.length - 1];
        arr.pop();
    }

    /// @dev delete element and replace it with a popped element
    /// @param index of element to remove
    function remove(uint256 index) public {
        arr[index] = pop();
    }

    /// @param index to update
    /// @param value is the new value being set
    function set(uint256 index, uint8 value) public {
        arr[index] = value;
    }
}
