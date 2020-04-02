--
-- db module.
--
local Log   = require "common.log_module"
local pcall = pcall;

local db_handler = {
    m_func_handle = {},
    m_init = false,
};

function db_handler:Init()
    -- init here.
    self.init = true;
end

function db_handler:Deal(sid, msg_id, data, id)
    local func = self.m_func_handle[msg_id];
    if func then
        pcall(func, self, sid, id, data);
    else
        Log:Crit("can not find " .. msg_id .. " dealer");
    end
end

-- try init if not do it.
if not db_handler.m_init then db_handler:Init() end
return db_handler;