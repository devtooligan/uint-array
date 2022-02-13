// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import "ds-test/test.sol";

import "./TinyArray.sol";


contract TinyArrayTest is DSTest {
    ITinyArray  tinyArr;

    function setUp() public {
        tinyArr = new TinyArray();
    }

    function testLength() public {
        assertEq(tinyArr.length(), 0);
    }

    function testPush() public {
        uint8 newEl = 0xab;
        tinyArr.push(newEl);
        assertEq(tinyArr.length(), 1);
        assertEq(tinyArr.val(0), 0xab);
        newEl = 0x99;
        tinyArr.push(newEl);
        assertEq(tinyArr.length(), 2);
        assertEq(tinyArr.val(1), 0x99);
        assertEq(tinyArr.val(0), 0xab);
        newEl = 0xfe;
        tinyArr.push(newEl);
        assertEq(tinyArr.length(), 3);
        assertEq(tinyArr.val(2), 0xfe);
        assertEq(tinyArr.val(1), 0x99);
        assertEq(tinyArr.val(0), 0xab);
    }
}
