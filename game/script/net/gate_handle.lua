--
-- gate prototol handler.
--
local pcall = pcall
local pb    = require "common.pb_module"
local Log   = require "common.log_module"
local Net   = require "common.tcp"

local gate_handler = {
    m_func_handle = {},
    m_init        = false,
};

function gate_handler:Init()
    self.m_func_handle[pb:MsgId("cs_enter_game_req_id")] = self.ProcessEnterGame;
    self.m_init = true;
    return true;
end

function gate_handler:ProcessEnterGame(server, data, id)
    local proto = pb:Decode("SProtoSpace.Phone", data);
    Log:Crit(proto.name .. ", " .. proto.phonenumber);

    -- send to.
    local bytes = pb:Encode("SProtoSpace.Phone", proto);
    Net:ServerTo(server, id, pb:MsgId("cs_enter_game_req_id"), bytes, #bytes);
end

function gate_handler:Deal(server, msg_id, data, attach_id)
    local func = self.m_func_handle[msg_id];
    if func then
        pcall(func, self, server, data, attach_id);
    else
        Log:Crit("can not find " .. msg_id .. " dealer");
    end
end

-- Init() if not do it.
if not gate_handler.m_init then gate_handler:Init() end
return gate_handler;