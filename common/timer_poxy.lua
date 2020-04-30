--
-- timer poxy module.
--
local timer = require "common.timer"


local timer_poxy = {
    timer_list = {}, -- timer id list.
};

function timer_poxy:ClearTimer()
    if not self.timer_list then return end

    for i = 1, #self.timer_list do
        timer:KillTimer(self.timer_list[i]);
    end
    self.timer_list = nil;
end

function timer_poxy:new(o)
    o = o or {};
    setmetatable(o, { __index = self, __gc = function(o) o:ClearTimer(); end });
    return o;
end

function timer_poxy:add(id)
    self.timer_list[#self.timer_list + 1] = id;
end

function timer_poxy:AddOnceTimer(delay, func, para)
    local id = timer:AddOnceTimer(delay, func, para);
    self:add(id);
    return id;
end

function timer_poxy:AddRepeatTimer(delay, func, para)
    local id = timer:AddRepeatTimer(delay, func, para);
    self:add(id);
    return id;
end

function timer_poxy:GetLeftTime(id)
    return timer:GetLeftTime(id);
end

function timer_poxy:KillTimer(id)
    return timer:KillTimer(id);
end

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
    end
    return timer:HasTimer(id);
end

function timer_poxy:RemoveTimer(id)
    self.timer_list[id] = nil;
end

return timer_poxy;

