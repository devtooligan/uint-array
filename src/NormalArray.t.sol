// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import "ds-test/test.sol";

import "./NormalArray.sol";


contract NormalArrayTest is DSTest {
    INormalArray  arr;

    function setUp() public {
        arr = new NormalArray();
    }

    function testLength() public {
        assertEq(arr.length(), 0);
    }

    function testPush() public {
        uint8 newEl = 0xab;
        arr.push(newEl);
        assertEq(arr.length(), 1);
        uint8[] memory ta = arr.getArr();
        assertEq(arr.val(0), 0xab);
        newEl = 0x99;
        arr.push(newEl);
        assertEq(arr.length(), 2);
        assertEq(arr.val(1), 0x99);
        assertEq(arr.val(0), 0xab);
        newEl = 0xfe;
        arr.push(newEl);
        assertEq(arr.length(), 3);
        assertEq(arr.val(2), 0xfe);
        assertEq(arr.val(1), 0x99);
        assertEq(arr.val(0), 0xab);

    }

}
