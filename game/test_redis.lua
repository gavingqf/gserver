local Redis = require "common.credis"
local Log   = require "common.log_module"

function redis_test()
    if not Redis:Init() then
        Log:Crit("redis init error");
        return false;
    end

    if not Redis:Connect(1, "127.0.0.1", 6379) then
        Log:Crit("connect redis error");
        return false;
    else
        Log:Crit("connect redis ok");
    end

    -- test sadd and smembers command.
    local ret = Redis:SetCmd("SADD gavin 1");
    ret = Redis:SetCmd("SADD gavin 2");
    local t = Redis:GetCmd("SMEMBERS gavin");
    if t then
        for i = 1, #t do
            Log:Crit(t[i]);
        end
    else
        Log:Crit("can not find gavin node");
    end

    return true;
end