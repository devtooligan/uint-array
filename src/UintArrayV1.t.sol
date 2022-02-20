// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import "ds-test/test.sol";

import "./UintArrayV1.sol";

contract UintArrayV1Test is DSTest {
    UintArrayV1 arr;
    UintArrayV1 arr30;

    function setUp() public {
        arr = new UintArrayV1();
        arr.push(uint8(0xff));
        arr30 = new UintArrayV1();
        arr30.push(uint8(0xff));
        for (uint256 index = 1; index < 31; ++index) {
            arr30.push(uint8(index));
        }
    }

    function testLength() public {
        assertEq(arr.length(), 1);
    }

    function testPushOne() public {
        arr.push(0xab);
        assertEq(arr.length(), 2);
        assertEq(arr.val(1), 0xab);
    }

    function testPushThirty() public {
        for (uint256 index = 1; index < 31; ++index) {
            arr.push(uint8(index));
            assertEq(arr.length(), index + 1);
            assertEq(arr.val(index), index);
        }
    }

    function testPop() public {
        assertEq(arr.length(), 1);
        assertEq(arr.pop(), uint8(0xff));
    }
    function testRead31() public view returns (uint256 sum) {
        for (uint256 index = 0; index < 31; ++index) {
            sum = sum + arr30.val(index);
        }
    }

    function testRemove() public {
        arr30.remove(0);
    }
}
