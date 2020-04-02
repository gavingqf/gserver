--
-- c wrap redis module
--
require "common.utility"

--[[
    all set command return bool
    and get command return table(maybe nil if fails)
    add opt(set, get) return error string.
]]


local Redis = {
    m_module = nil, -- credis new module.
}

-- create a new Redis.
function Redis:new()
    local obj = {};
    self.__index = self;
    setmetatable(obj, self);
    return obj;
end

-- init.
function Redis:Init()
    self.m_module = credis.new();
    return self.m_module ~= nil;
end

-- release.
function Redis:Reset()
    if self.m_module then
        self.m_module:redis_release();
        self.m_module = nil;
    end
end

--[[
return bool, errstring
local ret, err = Connect(ip, port);
if not ret then
    print("connect " .. ip .. ", " .. port .. ", error:" .. err);
end
--]]
function Redis:Connect(index, ip, port)
    return self.m_module:redis_connect(index, ip, port);
end

-- set key value
-- return bool, errstring
function Redis:Set(key, value)
    local req = BuildString("SET ", key, "  ", value);
    return self.m_module:redis_set(req);
end

-- add key value.
-- return bool, errstring
function Redis:Add(key, value)
    local req = BuildString("SADD ", key, " ", value);
    return self.m_module:redis_set(req);
end

-- get key：return table or nil, errstring
-- if return nil, then check errstring.
function Redis:Get(key)
    local req = BuildString("GET ", key);
    return self.m_module:redis_get(req);
end

-- delete key.
function Redis:Del(key)
    local req = BuildString("DEL ", key);
    return self.m_module:redis_set(req);
end

-- common command execution.
function Redis:SetCmd(cmd)
    return self.m_module:redis_set(cmd);
end
-- return table or nil
function Redis:GetCmd(cmd)
    return self.m_module:redis_get(cmd)
end

return Redis;

