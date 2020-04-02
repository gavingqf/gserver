--[[
    time meter class
]]
require "common.utility"
local table_concat   = table.concat;
local GetMilliSecond = GetTickCount
local Log            = require "common.log_module"

LTimeMeter = class(function(self, limit_time)
    -- limit time.
    self.m_limit_time = limit_time or 50;

    -- slot time array.
    self.m_slot_times = { GetMilliSecond() };
end);

function LTimeMeter:Stamp()
    self.m_slot_times[#self.m_slot_times+1] = GetMilliSecond();
    return self:_IsTimeOut();
end

function LTimeMeter:Out(Paras)
    local contents = {Paras};
    for i = 2, #self.m_slot_times do
        local diff = self.m_slot_times[i] - self.m_slot_times[i-1];
        if i ~= 2 then contents[#contents+1] = "--" end
        contents[#contents+1] = "[" .. diff .. "]";
    end
    self:_Log(table_concat(contents));
end

function LTimeMeter:Clear()
    self.m_slot_times = nil;
end

function LTimeMeter:Elapse()
    if #self.m_slot_times > 0 then
        return self.m_slot_times[#self.m_slot_times] - self.m_slot_times[1];
    else
        return 0;
    end
end

function LTimeMeter:_IsTimeOut()
    if #self.m_slot_times then
        return self.m_slot_times[#self.m_slot_times] >= self.m_slot_times[1] + self.m_limit_time;
    else
        return false;
    end
end

function LTimeMeter:_Log(Data)
    Log:Info(Data);
end