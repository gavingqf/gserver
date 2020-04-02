local Timer = require "common.timer"
local Log   = require "common.log_module"

function test_timer(server, id)
    for i = 1, 800000 do -- add timer.
        Timer:AddTimer(1 * 500, 1, function(para, id)
        end, {1, 2});
    end

    Timer:AddTimer(1 * 500, 1, function(para, id)
        Log:Crit("timer info: " .. para[1] .. " " .. para[2] .. "timer id:" .. id);
        -- common.exit_system();
    end, {3, 4});
    
    --[[
    -- gc test.
    Timer:AddTimer(1000, 1, function(para, id)
        -- collect garbage.
        --collectgarbage("collect");

        -- test lua memory.
        local mem = collectgarbage("count") * 1024;
        Log:Crit("== now gc: " .. mem .. " ==");
    end,nil);
    --]]
end