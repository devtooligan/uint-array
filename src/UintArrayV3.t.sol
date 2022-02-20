// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

import "ds-test/test.sol";

import "./UintArrayV3.sol";

contract UintArrayV3Test is DSTest {
    UintArrayV3 arr;
    UintArrayV3 arr30;

    function setUp() public {
        arr = new UintArrayV3();
        arr.set(0, uint8(0xff));
        arr30 = new UintArrayV3();
        for (uint256 index = 0; index < 32; ++index) {
            arr30.set(index, uint8(index));
        }
    }

    function testLength() public {
        assertEq(arr.length(), 32);
    }

    function testRead31() public view returns (uint256 sum) {
        for (uint256 index = 0; index < 31; ++index) {
            sum = sum + arr30.val(index);
        }
    }

}
