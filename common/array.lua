--[[
lua array wrapper.
--]]

LArray = class(function(self)
    self.m_array = {};
end);

function LArray:size()
    return #self.m_array;
end

function LArray:clear()
    for i = 1, self:size() do
        self.m_array[i] = nil;
    end
    self.m_array = nil;
    -- reset m_array.
    self.m_array = {};
end

function LArray:push_back(v)
    self.m_array[#self.m_array + 1] = v;
end

-- remove all v values
function LArray:remove(v)
    for i = 1, self:size() do
        if self.m_array[i] == v then
            self.m_array[i] = nil;
        end
    end
end

function LArray:find(v)
    for i = 1, self:size() do
        if self.m_array[i] == v then
            return true;
        end
    end
    return false;
end

function LArray:empty()
    return self:size() == 0;
end

function LArray:front()
    if self:empty() then
        return nil;
    else
        return self.m_array[1];
    end
end

function LArray:back()
    if self:empty() then
        return nil;
    else
        return self.m_array[#self.m_array];
    end
end

function LArray:value(index)
    return self.m_m_array[index];
end

function LArray:GetData()
    return self.m_array;
end
