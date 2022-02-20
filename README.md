# uint-array

A array implementations using a uint256 and some bitwise operations.

## V1 uint8[] - max length 32
The first implementation is a dynamic uint8[] array based on a uint256.  Length is stored in state


## V2 uint8[] - max length 31
This is also a dynamic uint8[] array based on a uint256.  However, instead of storing length in state, length is stored in the first byte of the uint255 "array"

This saves some SSTORE's but reduces the maximum length of the array to 31.

Additionally, in V2 elements in the "array" are changed using arithmetic.

Here is an example using decimals for ease of explanation.  Each 2 digits represents one element of the array, but the first element is used to store the length of the array.

stored uint array value:
 ┌┬ 04 represents length of 04
`0402040608`
   └┴ 02 is the value of the element in index0. 04 is index1, 06 is index2, and 08 is index3

Let's say we want to change the value of index1 from 04 to 44:

Step 1 - calculate the difference between the new val and old => 44 -4 = 40.  So we want to add 40 to that 2nd element.
Step 2 - Apply the correct significant digits based on the index.  This element is 2 index slots to the left of the end but each slot holds 2 digits, so 10^(2*2) == 10^4 = 10000
Step 3 - multiply and add difference to "array" (40 * 10 ^4) == 400,000 =>  400,000 + 402,040,608 = 402,440,608 == `0402440608`


## V3 uint8[32] fixed - no push() or pop()
This is also a fixed uint8[32] array based on a uint256.  Because it's fixed, it does not need to store length.  But, because it is an fixed array, there are no `push()` or `pop()` fns.

# Findings

For comparison, I've created a `NormalArray` with the following interface which V1 and V2 of the UintArray conforms to.  Note V3 is a fixed array so does not have all the functionality.

```solidity
interface ArrayInterface {
    function getArr() external view returns(uint8[] memory);
    function val(uint256 index) external view returns(uint8);
    function push(uint8 value) external;
    function pop() external returns(uint8 value);
    function length() external view returns (uint8);
    function remove(uint256 index) external;
    function set(uint256 index, uint8 value) external;
}
```
Next I created a test suite to test the functionality and compare gas usage.  Not surprisingly, for the most part none of these UintArray implementations beat out the native uint8[] implementation when it comes to storing/updating new values.  In spite of the optimizations, this code can't compete with the lower level optimizations used by Solidity's native implementation when it comes to writing.  However, there are some significant gas savings seen when it comes to reading the "array".

Here are the reporte gas numbers:

```
Running 6 tests for NormalArrayTest.json:NormalArrayTest
[PASS] testLength() (gas: 1066)
[PASS] testPushOne() (gas: 3878)
[PASS] testPushThirty() (gas: 116373)
[PASS] testRead31():(uint256) (gas: 47780)
[PASS] testRemove() (gas: 2757)

Running 6 tests for UintArrayV1Test.json:UintArrayV1Test
[PASS] testLength() (gas: 1089)
[PASS] testPushOne() (gas: 4367)
[PASS] testPushThirty() (gas: 250668)
[PASS] testRead31():(uint256) (gas: 40514)
[PASS] testRemove() (gas: 18566)

Running 6 tests for UintArrayV2Test.json:UintArrayV2Test
[PASS] testLength() (gas: 1206)
[PASS] testPushOne() (gas: 4874)
[PASS] testPushThirty() (gas: 146253)
[PASS] testRead31():(uint256) (gas: 45040)
[PASS] testRemove() (gas: 3875)

Running 2 tests for UintArrayV3Test.json:UintArrayV3Test
[PASS] testLength() (gas: 943)
[PASS] testRead31():(uint256) (gas: 35997)
```

 - `push()` V1 and V2 couldn't even come close to the standard uint8[] array
 - `pop()` Again the normal array is the winner here, but not by as much
 - `remove()` This one was particularly harsh on V1 which stores its length in state
 - `length()` The limited use V3 came in a small winner on this less important function
 - `val()` reading the values was a big winner for UintArray accross the board.  It was
    limited to 31 because that is the max of V2.  V3 came in a huge winner here with over
    a 23% reduction in gas

# Use Cases
This was done as an experiment for fun and some practice using bitwise operations.  The limitation of this array is that it can only hold 32 (or 31) elements.  Because all of the optimizations come from read, something like this could only be used with an array that will be read-only or one that is updated very infrequently.  One idea that comes to mind is the list of Id's for collateral types in a multi-collateral vault.  If you used uint8 numbers as Id's for your assets and if you knew you were only ever going to have 32 or less then setting up a `UintArray` in the constructor might save some gas.

