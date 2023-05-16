---@meta

--  ╭──────────────────────────────────────────────────────────╮
--  │                          carray                          │
--  ╰──────────────────────────────────────────────────────────╯

---@class CArray_Mod
local carray_m = {}

---@class CArray
local CArray = {}

---@alias carray userdata
---@alias carray.dtypes
---| "'char'"               1 byte,                           0 - 255
---| "'uchar'"              1 byte,                           0 - 255
---| "'schar'"              1 byte,                        -128 - 127
---| "'unsigned char'"      1 byte,                           0 - 255
---| "'signed char'"        1 byte,                        -128 - 127
---| "'int'"                4 bytes,             -2,147,483,648 - 2,147,483,647
---| "'uint'"               4 bytes,                          0 - 4,294,967,295
---| "'unsigned int'"       4 bytes,                          0 - 4,294,967,295
---| "'short'"              2 bytes,                    -32,768 - 32,767
---| "'ushort'"             2 bytes,                          0 - 65,535
---| "'unsigned short'"     2 bytes,                          0 - 65,535
---| "'long'"               8 bytes, -9,223,372,036,854,775,808 - 9,223,372,036,854,775,807
---| "'ulong'"              8 bytes,                          0 - 18,446,744,073,709,551,615
---| "'unsigned long'"      8 bytes,                          0 - 18,446,744,073,709,551,615
---| "'long long'"          8 bytes, -9,223,372,036,854,775,808 - 9,223,372,036,854,775,807
---| "'llong'"              8 bytes, -9,223,372,036,854,775,808 - 9,223,372,036,854,775,807
---| "'ullong'"             8 bytes,                          0 - 18,446,744,073,709,551,615
---| "'unsigned llong'"     8 bytes,                          0 - 18,446,744,073,709,551,615
---| "'unsigned long long'" 8 bytes,                          0 - 18,446,744,073,709,551,615
---| "'float'"              4 bytes,               1.175494351E - 38  3.402823466E + 38
---| "'float32'"            8 bytes
---| "'float64'"           16 bytes
---| "'double'"             8 bytes,        2.2250738585072014E - 308 1.7976931348623158E + 308
---| "'int8'"               2 bytes
---| "'uint8'"              2 bytes
---| "'int16'"              4 bytes
---| "'uint16'"             4 bytes
---| "'int32'"              8 bytes
---| "'uint32'"             8 bytes
---| "'int64'"             16 bytes
---| "'uint64'"            16 bytes
---| "'integer'"            Lua integer
---| "'number'"             Lua number

---Create a new `CArray`
---@param type carray.dtypes type name of the elements
---@param size? integer number of the elements; if given, values are initialized to 0
---@return CArray
function carray_m.new(type, size)
end

---Get elements from the array. 1-indexed, like Lua
---
---## Example
---```lua
---  -- gets last 3 elements of array
---  array:get(-3,-1)
---```
---@param start integer position of first element to get from array (can be negative)
---@param finish? integer position of last element of array to get; if nil, finish = start (can be negative)
---@return integer|string
function CArray:get(start, finish)
end

---Sets the given elements at the specified position of the array object
---Can set string values only if array type is `char`, `uchar`, or `schar`
---Index must be:
---   - `1 <= pos <= array:len()`
---   - `-array:len() <= pos -1`
---@param pos integer index of first elem that is to be set into array (can be negative)
---@param ... integer|string elems/objects that are set into the array beginning at `pos`
---@return CArray
function CArray:set(pos, ...)
end

---Appends the given elements to the end of the array object
---Can set string values only if array type is `char`, `uchar`, or `schar`
---@param ... integer|string elems/objects that are appended to end of array
---@return CArray
function CArray:append(...)
end

---Inserts the given elements at the specified position of the array object
---Index must be:
---   - `1 <= pos <= array:len() + 1`
---@param pos integer index where first element is to be inserted
---@param ... integer|string elemens/objects that are inserted at specified `pos` of array
---@return CArray
function CArray:insert(pos, ...)
end

---Sets elements of another array `array2` to specified position `pos0` into array.
---Given elements must fit into the current array length
---
---## Example
---```lua
---  -- sets first three elements of `array2` to the array at position 1
---  array:setsub(1, array2, 1, 3)
---  -- sets last three elements of `array2` into the array object at position 1
---  array:setsub(1, array2, -3, -1)
---```
---@param pos0 integer index where first element is to be set
---@param array2 integer[]|string[] source array
---@param pos1 integer index of first element to be set from `array2`
---@param pos2 integer index of last element of `array2` to be set
---@return CArray
function CArray:setsub(pos0, array2, pos1, pos2)
end

---Appends elements of another array `array2` to the end of array.
---
---## Example
---```lua
---  -- appends first three elements of `array2` to the array
---  array:appendsub(array2, 1, 3)
---  -- appends last three elements of `array2` to the array
---  array:appendsub(array2,-3,-1)
---```
---@param array2 integer[]|string[]
---@param pos1 integer index of first element to append from `array2`
---@param pos2 integer index of last element of `array2` to append
---@return CArray
function CArray:appendsub(array2, pos1, pos2)
end

---Inserts elements of another array `array2` to the specified position `pos0` into array
---
---## Example
---```lua
---  -- inserts the first three elements of `array2` to the array at position 1
---  array:insertsub(1, array2, 1, 3)
---  -- inserts the last three elements of `array2` into the array object at position 1
---  array:insertsub(1, array2, -3, -1)
---```
---@param pos0 integer index where first element is to be inserted
---@param array2 integer[]|string[] source array
---@param pos1 integer index of first element to insert from `array2`
---@param pos2 integer index of last element of `array2` to insert
---@return CArray
function CArray:insertsub(pos0, array2, pos1, pos2)
end

---Removes elements from the array
---
---## Example
---```lua
---  -- removes the first element of the array
---  array:remove(1)
---  -- removes the last three elements of the array
---  array:remove(-3,-1)
---```
---@param pos1 integer index of first element to remove from array
---@param pos2? integer index of last element to remove from array
---@return CArray
function CArray:remove(pos1, pos2)
end

---Returns the number of elements in the array object
---@return integer
function CArray:len()
end

---Returns the element type name as string value
---@return carray.dtypes
function CArray:type()
end

---Returns the element base type name as string value
---@return "'int'"|"'uint'"|"'float'"
function CArray:basetype()
end

---Returns the number of bits per element as integer value
---@return integer bits_per_elem
function CArray:bitwidth()
end

---Resets the array to length `0`
---@param shrink? boolean if true, internal capacity of array is also set to 0 (i.e., memory is freed)
---@return CArray
function CArray:reset(shrink)
end

---Sets how many elements can be stored in the array
---If the new length is larger than the old length, new elements are initialized with zero.
---If the new length is lesser than the old length, existing elements are discarded from behind.
---@param newlen integer new length of the array
---@param shrink? boolean if true, internal capacity is reduced ot match the length
---@return CArray
function CArray:setlen(newlen, shrink)
end

---Sets or gets the reserve count.
---Reserve count denotes number of new elements that
---can be appended to the array without the need to re-allocate the array's memory.
---
---Returns current reserve count if no argument is given, otherwise the array object is returned
---@param count? integer N > 0 ? reserve N elements : memory greater than needed is freed
---@return integer|CArray
function CArray:reserve(count)
end

---Returns array elements as string value for arrays that have element type `schar`, or `uchar`
---
---## Example
---```lua
---  -- returns the first two chars of the array as string
---  array:tostring(1,2)
---  -- returns the last three chars of the array as string
---  array:tostring(-3,-1)
---```
---@param pos1? integer index of first element to get from array
---@param pos2? integer index of last element to get from array
---@return string
function CArray:tostring(pos1, pos2)
end

---Returns `true` if the arrays have same type and number of elements
---@param array2 CArray
---@return boolean
function CArray:equals(array2)
end

---Appends the content of the given file to the array.
---@param file string or file handle
---@param pos? integer maximum number of elements that are read from file
---@return CArray
function CArray:appendfile(file, pos)
end
