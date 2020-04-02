--[[
    lua bit module, not over 64.
--]]
BIT_VALUE = { -- just for global use.
    ONE = 1,
    ZERO = 2,
}
-- for 64 number value limit.
local max_bit_count = 64

LBit = class(function(self, _max_bit_count, default_index)
    _max_bit_count = _max_bit_count or 1;
    if _max_bit_count >= max_bit_count then
        _max_bit_count = max_bit_count;
    end

    self.m_value = {};
    self.m_bit_count = _max_bit_count;

    if default_index and default_index < _max_bit_count then
        self.m_value[default_index] = BIT_VALUE.ONE;
    end
end);

function LBit:Set(index, value)
    if index >= self.m_bit_count then
        return false;
    end

    local v = BIT_VALUE.ZERO;
    if value > 0 then
        v = BIT_VALUE.ONE;
    else
        v = BIT_VALUE.ZERO;
    end
    self.m_value[index] = v;
    return true;
end

function LBit:Get(index)
    if index >= self.m_bit_count then
        return BIT_VALUE.ZERO;
    end

    if not self.m_value[index] then
        return BIT_VALUE.ZERO;
    else
        return BIT_VALUE.ONE;
    end
end

function LBit:Clear()
    self.m_value = {};
end

function LBit:Value()
    local value = 0;
    for k, v in pairs(self.m_value) do
        if v == BIT_VALUE.ONE then
            value = value + (2 ^ k);
        end
    end
    return value;
end


--[[
    -- test code.
    local bit = LBit(16);
    bit:Set(4, 1);
    local f = bit:Get(4);
    if f == BIT_VALUE.ONE then
        print("flag = " .. 1);
    end
]]