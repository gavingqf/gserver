-- [[
-- timer poxy module. just wraper timer info.
-- ]]

local timer = require "common.timer"
require "common.class"


 timer_poxy = class();
 function timer_poxy:Ctor()
    self.timer_list = {};
 end

function timer_poxy:ClearTimer()
    if not self.timer_list then return end

    for i = 1, #self.timer_list do
        timer:KillTimer(self.timer_list[i]);
    end
    self.timer_list = nil;
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
    local r = timer:KillTimer(id);
    self:RemoveTimer(id);
    return r;
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
    else
        return timer:HasTimer(id);
    end
end

function timer_poxy:RemoveTimer(id)
    self.timer_list[id] = nil;
end

return timer_poxy;

