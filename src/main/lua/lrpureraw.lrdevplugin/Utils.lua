---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dieterstockhausen.
--- DateTime: 05.05.21 19:19
-------------------------------------------------------------------------------
local Utils = {}
-------------------------------------------------------------------------------
function Utils.arraySize(array)
    count = 0
    for _ in pairs(array) do count = count + 1 end
    return count
end
-------------------------------------------------------------------------------
function Utils.starts_with(str, start)
    return str:sub(1, #start) == start
end
-------------------------------------------------------------------------------
function Utils.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
-------------------------------------------------------------------------------

return Utils