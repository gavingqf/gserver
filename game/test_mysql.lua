
local Log   = require "common.log_module"
local MYSQL = require "common.mysql"

function mysql_test()
    -- get tick count.
    Log:Crit("gettickcount: " .. GetTickCount());

    -- sync query
    Log:Crit("sync result:");
    local ret, err, res = MYSQL:Sync_query("select charid, account from role;");
    if res then
        for i = 1, #res do
            Log:Crit("charid:" .. res[i][1] .. ", account:" .. res[i][2]);
        end
    end

    -- async result.
    Log:Crit("async result:");
    local r = MYSQL:Async_query("select charid, account from role;", nil, function(ret, err, res)
        if not ret then
            Log:Crit("execute sql error: " .. err);
            return ;
        end
        
        if res then
            for i = 1, #res do
                Log:Crit("charid:" .. res[i][1] .. ", account:" .. res[i][2]);
            end
        end
    end);

    -- escape data.
    local s = MYSQL:Escape("select * from role");
    Log:Crit(s);

    -- test qps
    local t1 = GetTickCount();
        for i =  1, 10000 do
            MYSQL:Sync_query("select * from test.role where charid = 1", 1);
        end
    local t2 = GetTickCount();
    Log:SCrit("time: " .. (10000 / (t2 - t1)) * 1000);

end

-- test mysql.
mysql_test();