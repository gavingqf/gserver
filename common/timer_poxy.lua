-- [[
-- timer poxy module. just wraper timer info for a class.
-- ]]

local timer = require "common.timer"
require "common.class"
local log = require "common.log_module"

 timer_poxy = class();
 function timer_poxy:Ctor()
    self.timer_list = {};
 end

 function timer_poxy:Dtor()
    self:ClearTimer();
    log:Crit("timer proxy is gc.");
 end

 function timer_poxy:GetName()
    return "timer_poxy";
 end

 -- clear all timer.
function timer_poxy:ClearTimer()
    if not self.timer_list then return end

    for i = 1, #self.timer_list do
        timer:KillTimer(self.timer_list[i]);
    end
    self.timer_list = {};
end

-- add timer id.
function timer_poxy:add(id)
    self.timer_list[#self.timer_list + 1] = id;
end

-- add once timer.
function timer_poxy:AddOnceTimer(delay, func, para)
    local id = timer:AddOnceTimer(delay, func, para);
    self:add(id);
    return id;
end

-- add repeat timer.
function timer_poxy:AddRepeatTimer(delay, func, para)
    local id = timer:AddRepeatTimer(delay, func, para);
    self:add(id);
    return id;
end

-- get left time of timer.if there is no id, then return -1.
function timer_poxy:GetLeftTime(id)
    if not self:HasTimer(id) then
        return -1;
    else
        return timer:GetLeftTime(id);
    end
end

-- kill timer(check timer id).
function timer_poxy:KillTimer(id)
    if self:HasTimer(id) then
        local r = timer:KillTimer(id);
        if r then
            self:RemoveTimer(id);
        end
        return r;
    else
        return false;
    end
end

-- has timer
function timer_poxy:HasTimer(id)
    local find = false;
    for i = 1, #self.timer_list do
        if (self.timer_list[i] == id) then
            find = true;
            break;
        end
    end
    if false == find then
        return false;
    else
        return timer:HasTimer(id);
    end
end

-- remove timer.
function timer_poxy:RemoveTimer(id)
    self.timer_list[id] = nil;
end

return timer_poxy;

