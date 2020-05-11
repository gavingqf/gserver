--
-- client prototol handler.
--
local pb     = require "common.pb_module"
local Log    = require "common.log_module"
local pcall = pcall;
local Timer  = require "common.timer"

global_qps_count = 0;

local client_handler = {
    m_func_handle = {},
    m_init        = false;
};

function client_handler:Init()
    self.m_init = true;
    self.m_func_handle[pb:MsgId("cs_chat_req_id")] = self.ProcessChatReq;
    self.m_func_handle[pb:MsgId("cs_time_req_id")] = self.ProcessTimeReq;
    self.m_func_handle[1] = self.ProcessUserData;
    -- more here.
    return true;
end

function client_handler:ProcessUserData(role, data, len)
    global_qps_count = global_qps_count + 1;
    Log:Crit("data: " .. data);
end

function client_handler:ProcessChatAck(role, data, len)
    local ack = pb:Decode("SProtoSpace.sc_chat_ack", data);
    Log:Crit("ack: " .. ack.ret);
end

function client_handler:ProcessChatReq(role, data, len)
    if not role then return end

    -- send message.
    local chat = pb:Decode("SProtoSpace.cs_chat_req", data);
    Log:Crit("chat :" .. chat.content);

    -- chat ack.
    local ack = {
        ret = 1,
    }
    role:SendMessage("sc_chat_ack_id", "SProtoSpace.sc_chat_ack", ack);
end

function client_handler:ProcessTimeReq(role, data, len)
    -- local now = os.date("%Y-%m-%d %H:%M:%S", os.time());
    local time_ack = {
        time = "gavin123",s
    }
    role:Send("SProtoSpace.sc_time_ack", time_ack);

    -- add count.
    global_qps_count = global_qps_count + 1;
end

function client_handler:Deal(role, msg_id, data, len)
    if not data or not len then
        Log:Crit("find " .. msg_id .. " message data is nil");
        return ;
    end

    local func = self.m_func_handle[msg_id];
    if func then
        pcall(func, self, role, data, len);
    else
        Log:Crit("can not find " .. msg_id .. " dealer");
    end
end

-- Init() if not do it.
if not client_handler.m_init then 
    client_handler:Init()

    Timer:AddTimer(60*1000, 1, function(para)
        Log:Crit("qps: " .. global_qps_count/60);
        global_qps_count = 0;
    end);

end
return client_handler;