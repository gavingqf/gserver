-- timer wrapper.
local timer = timer;
local Log   = require "common.log_module"
require "common.utility"

-- timer function add timer_id parameter.

-- add timer ret.
timer_ret = {
    ADD_TIMER_FAIL = -1,     -- add fail
	ADD_TIMER_SUCC = 0,      -- success
}

-- timer module
local TimerModule = {
}

-- delay is timer time: unit is millisecond
-- circle whether is circle timer: true or >= 1
-- function(para, timer_id) end
-- return timer id, nil if error and err is error string
-- para is func callback parameter
-- eg: AddTimer(time, circle, function(para) end, para)
-- delay can from GetNow() of utility.lua
function TimerModule:AddTimer(delay, circle, func, para)
    if not delay then
        Log:Crit("timer time is nil");
        return ;
    end

    if delay < 0 then
        Log:Crit("delay time error")
    end

    if not func then
        Log:Crit("timer func is nil");
        return ;
    end

    local id, err = timer.add_timer(delay, circle, para, func);
    if not id then Log:Crit(BuildString("add timer error: ", err)) end
    return id;
end

-- add once timer
function TimerModule:AddOnceTimer(delay, func, para)
    return self:AddTimer(delay, 0, func, para);
end

-- add repeated timer
function TimerModule:AddRepeatTimer(delay, func, para)
    return self:AddTimer(delay, 1, func, para);
end

-- kill AddTimer return value.
function TimerModule:KillTimer(id)
    if not id then
        Log:Crit("timer id is nil");
        return ;
    end
    timer.kill_timer(id);
end

-- get left time of timer id.
-- if there is not id timer, then return -1.
function TimerModule:GetLeftTime(id)
    return timer.get_left_time(id);
end

-- has timer, if killed, then return false.
function TimerModule:HasTimer(id)
    return timer.has_timer(id);
end

return TimerModule;
