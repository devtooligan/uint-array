// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

interface ArrayInterface {
    function getArr() external view returns(uint8[] memory);
    function val(uint256 index) external view returns(uint8);
    function push(uint8 value) external;
    function pop() external returns(uint8 value);
    function length() external view returns (uint8);
    function remove(uint256 index) external;
    function set(uint256 index, uint8 value) external;
}
