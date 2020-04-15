--
-- tcp(not udp) module, server and client wrapper.
--
local net = net;
local Log = require "common.log_module"
require "common.utility"

local TCPModule = {

}

function TCPModule:Init()
    return net.net_init();
end

-- return true or false, error message.
function TCPModule:HttpStart(ip, port, page, data)
    local r, msg = net.http_start(ip, port, page, data);
    if not r then 
        Log:SCrit("http start error: " .. msg);
    end
    return r;
end

-- http client get:
--                 get (ip, port, page, data)
function TCPModule:HttpGetReq(ip, port, page, data)
    local r, data = net.http_get(ip, port, page, data);
    if false == r then
        Log:Crit("http get error: " .. data);
    end
    return data;
end
-- http client post:
--                 post(ip, port, page, data)
function TCPModule:HttpPostReq(ip, port, data, func)
    local r, data = net.http_post(ip, port, data, func);
    if false == r then
        Log:Crit("http get error: " .. data);
    end
    return data;
end

-- tcp listen on (ip, port)
function TCPModule:Listen(ip, port)
    local ret, err = net.tcp_listen(ip, port);
    if not ret then
        Log:SCrit(BuildString("listen on (", ip, ", ", port, ") error: ", err));
    end
    return ret;
end

-- tcp connect server (ip, port)
function TCPModule:Connect(ip, port)
    local connect_ret, err = net.tcp_connect(ip, port);
    if not connect_ret then
        Log:SCrit(BuildString("connect to (", ip,  ", ", port, ") .. err"));
    end
    return connect_ret;
end

function TCPModule:NodeInit(node_config, ip_config)
    local node_ret, err = net.node_init(node_config, ip_config);
    if not node_ret then
        Log:SCrit(BuildString("node init error: ", err));
    end
    return node_ret;
end

-- msg id, attach_id is inner id.
function TCPModule:ServerTo(server_id, msgid, data, attach_id)
    attach_id = attach_id or 0;
    return net.server_send(server_id, attach_id, msgid, data, #data);
end

function TCPModule:ServerToType(type, msgid, data, attach_id)
    attach_id = attach_id or 0;
    return net.server_send_type(type, attach_id, msgid, data, #data);
end

-- msg id.
function TCPModule:ClientTo(session, msgid, data)
    return net.client_send(session, msgid, data, #data);
end

-- close
function TCPModule:Close(session)
    net.client_close(session);
end

return TCPModule;