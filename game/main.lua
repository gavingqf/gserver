-- package.
package.path = "./?.lua;"
package.path = package.path .. common.get_exe_path() .. "/script/?.lua;"
package.path = package.path .. common.get_exe_path() .. "/../?.lua"

local common = common;
local pb = require "common.pb_module"
require "common.class"
require "common.macros"
require "common.utility"
local json = require "common.json"
local LSessions = require "common.sessions"

-- load proto method.
local function LoadProto()
    pb:Load_path({"./script"});
    pb:Load_file("base.proto");
    return true;
end
if not LoadProto() then error("load proto error") end


--[[
    gserver1.0 version, include tcp, mysql, timer, log, redis and so no which is just for server framework.
    add http server.
]]

-- mysql module
local MYSQL           = require "common.mysql"

-- tcp
local TCP             = require "common.tcp"

-- log module
local Log             = require "common.log_module"

-- timer
local Timer           = require "common.timer"

require "role.role"
local rolemgr         = require "role.role_manager"

-- handler.
local gate_handler    = require "net.gate_handle"
local db_handler      = require "net.db_handler"
local client_handler  = require "net.client_handle"

-- manager class.
local servers         = require "net.server"
local clients         = require "net.clients"
-- redis module
local Redis           = require "common.credis"
-- astar module
local Astar           = require "common.castar"

require "test_timer"
require "test_redis"

----------------------------cpp to lua interface: --------------------------------
-- log interface: log_module.lua
-- crit(content)  : asyncronous log
-- scrit(content) : syncronous log
-- warn(content)
-- swarn(content)
-- info(content)
-- sinfo(content)

-- net interface: tcp.lua
-- net_init() : must init if use tcp_listen, tcp_connect api.
-- node_init(pipe_config, ip_config) server connecting init.
-- tcp_listen(ip, port)
-- tcp_connect(ip, port)
-- server_send(server_id, attach_id, msg_id, data, len)
-- client_send(client_id, data, len);
-- client_close(session)
-- http_start(ip, port, function() return "" end)

-- timer interface: timer.lua
-- id = add_timer(time, circle, para, funcion)
-- kill_timer(id)
-- get_left_time(id);

-- common
-- local_server_id
-- rand()          : rand 
-- now()           : time now
-- get_exe_path    : exe path
-- md5             ： md5
-- build_client_head: get client head
-- exit_system     : exit system.
-- get_session_info: get session info, return ip and port.

--db interface: mysql.lua
-- mysql_init() 
-- mysql_connect(group, ..., count);
-- mysql_query_no_res(group, index, sql):  return update count.
-- mysql_query_with_res(group, index, sql): return ret, res.
-- mysql_async_query_no_res(group, index, sql, function(ret) end)
-- mysql_async_query_with_res(group, index, sql, function(ret, res) end)
-- mysql_escape(data)

-- redis interface：credis.lua
-- redis 
--

--
-- user implementation method:
-- server connecting:
-- on_server_net_data()
-- on_server_net_connect()

-- client connecting:
-- on_client_net_data()
-- on_client_connect()
--

-- system close callback(can use ctrl + c to exit)
-- on_system_close
-----------------------------------------------------------------------------------

--[[
    This framework proto format: msg_id + msg_data
    All protocols are packed and unpacked with lua_protobuf
]]

-- global init.
-- listen server (ip, port)
function init()
    -- variable check.
    global_variable_check();

    -- tcp init.
    TCP:Init();

    -- node init.
    local node_ret = TCP:NodeInit("server_node_cfg.xml", "server_ip_list.xml");
    if not node_ret then
        Log:SCrit("init node error");
        return false;
    else
        Log:SCrit("init node succ");
    end

    -- listen server.
    local tcp_ret = TCP:Listen("127.0.0.1", 6666);
    if not tcp_ret then
        return false;
    end
    -- log out.
    Log:Crit("listen ok");
   
    -- init mysql.
    if not MYSQL:Init(MAIN_MYSQL_HANDLE, MAIN_MYSQL_COUNT) then
        Log:SCrit("mysql init error");
        return false;
    end

    --
    -- connect mysql.
    --
    local r = MYSQL:Connect("127.0.0.1", 3306, "root", "123456", "test", "utf8");
    if not r then
        return false;
    end
    Log:Crit("connect mysql ok");

    --[[
    local data = "gavin";
    local data_md5 = common.md5(data, #data);
    Log:Crit(data_md5);
    --]]

     --[[ http client interface.
    local ret, data = net.http_post("127.0.0.1", "8000", "/?type=inner", "");
    if ret then Log:Crit("data: " .. data) end
    --]]
    local data = TCP:HttpGetReq("127.0.0.1", "8000", "/?type=inner", "");
    Log:Crit("data: " .. data);
    
    -- file is require file path, para is require parameter like (a & b).
    -- must return data or nil.
    local r = TCP:HttpStart("0", "8080", function(url, method, para)
        --[[
        if para then 
            Log:Crit("para is: " .. para);

            local v = Split(para, "&");
            for i = 1, #v do
                Log:Crit(v[i]);
            end
        end
        
        local f = io.open(file, "r");
        if not f then return "file can not find" end
        local t = f:read("*all");
        f:close();
        return t;
        --]]
        Log:Crit("url:" .. url);
        Log:Crit("method:" .. method);
        -- Log:Crit("para:" .. para);
        local ret = { ip = "127.0.0.1", port = 8001, };
        return json.encode(ret);
    end);
    if not r then
        Log:Crit("http error!");
    end

    return true;
end

-----------------------system close callback--------------
-- must do something to avoid data removed.
function on_system_close()
    -- system close callback.
    Log:SCrit("system is closed");

    -- save all to database.
    rolemgr:SaveAll();

    -- wait for all sql executed.
    MYSQL:Wait();
end
----------------------------------------------------------
-------------------------------------server info start--------------------------------------------
-- server:     server id.
-- attach_id:  inner attach id.
-- msg_id:     msg id.
-- data:       binary data.
-- net data: id, sid, msg_id, data.
function on_server_net_data(server, attach_id, msg_id, data, len)
    local local_server_id = common.local_server_id();
    local far_type    = common.get_server_type(server);
    local local_type  = common.get_server_type(local_server_id);

    -- server message handler
    if far_type == ServerType.GATE_SERVER_TYPE and local_type == ServerType.GAME_SERVER_TYPE then
        gate_handler:Deal(server, msg_id, data, attach_id);
    elseif far_type == ServerType.DB_SERVER_TYPE and local_type == ServerType.GAME_SERVER_TYPE then
        db_handler:Deal(server, msg_id, data, attach_id);
    end
end


-- net connect
-- connected true connect, else if disconnect.
-- server is far id.
function on_server_net_connect(server, connected)
    local local_server_id = common.local_server_id();
    local far_type = common.get_server_type(server);
    if connected then -- connect
        servers:Add(server);
    else              -- disconnect
        servers:Remove(far_type, server);
    end
end
---------------------------------------------------server info end-----------------------------------------------


--------------------------------client start-------------------------
-- id is client id.
-- data and len is recv message info.
function on_client_net_data(session, msg_id, data, len)
    local role = clients:Find(session);
    client_handler:Deal(role, msg_id, data, len);
end

-- id is client id.
-- connected whether is connected: true or false.
function on_client_connect(session, connected)
    if connected then
        local LSession = LSessions:create(session);
        local ip, port = LSession:GetIP(), LSession:GetPort();
        Log:Crit(BuildString("find ", session, "(", ip, ", ", port, ") connect in"));

        local role = rolemgr:Create();
        role:SetSession(session);
        clients:Add(session, role);

        -- OnConnected;
        role:OnConnected();

        -- send it circlely.
        Timer:AddTimer(1 * 100, 1, function(para, id)
            local sess = para[1];
            local c = para[2];
            if c == 50 then
                TCP:Close(sess);
                Timer:KillTimer(id);
                return ;
            else
                para[2] = c + 1;
            end

            local data = "gavingqf@126" .. GetRand(1, 100000000000);
            TCP:ClientTo(sess, 1, data);
        end, {session, 0});
    else
        local LSession = LSessions:get(session);
        assert(LSession);
        if not LSession then
            Log:Crit("can not find " .. session .. " lua session");
            return ;
        end
        local ip, port = LSession:GetIP(), LSession:GetPort();
        Log:Crit(BuildString("find ", session, "(", ip, ", ", port, ") disconnect out"));
        
        -- remove it from sessions.
        LSessions:remove(session);

        local role = clients:Find(session);
        if role then
            role:OnExit();
            clients:Remove(session);
        else
            Log:Crit(BuildString("can not find ", session, " role info"));
        end

        -- connect again.
        Timer:AddTimer(2 * 1000, 0, function(para, id)
            TCP:Connect("127.0.0.1", 8886);
        end);
    end
end
--------------------------------client end---------------------------

-- init all.
if not init() then Log:Crit("== init error ==") end

test_timer();
-- redis_test();