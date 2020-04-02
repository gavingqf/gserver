-- role module.
local rolemgr = require "role.role_manager"
local pb      = require "common.pb_module"
local Net     = require "common.tcp"
local Log     = require "common.log_module"
local Timer   = require "common.timer"
local MYSQL   = require "common.mysql"
local utility = require "common.utility"

LRole = class();
function LRole:Ctor()
    -- id.
    self.m_uuid    = nil;

    -- session id.
    self.m_sid     = nil;

    -- obj id
    self.m_objid   = nil;

    -- state
    self.state     = nil;

    -- timer list.
    self.m_timers  = {};

    self.m_account = nil;

    self.m_name    = nil;
end

function LRole:Init()
    self.m_uuid    = GetRand(0, 10000000000000);
    self.m_account = "gavin" .. GetRand(10000, 300000000000000);
    self.m_name    = "krssy" .. GetRand(40000000, 10000000000000);
end

function LRole:Release()
    -- kill all timers.
    for i = 1, #self.m_timers do
        Timer:KillTimer(self.m_timers[i]);
    end

end

function LRole:SetObjId(id)
    self.m_objid = id;
end

function LRole:GetObjId()
    return self.m_objid;
end

function LRole:SetSession(session)
    self.m_sid = session;
end

function LRole:GetSession()
    return self.m_sid;
end

function LRole:SetState(state)
    self.m_state = state;
end

-- semd binary
function LRole:SendBinary(msg_id, binary)
    if not self.m_sid then
        Log:Crit("session is nil");
        return ;
    end
    Net:ClientTo(self.m_sid, msg_id, binary, #binary);
end

-- send message
function LRole:SendMessage(msg_id_name, msg_name, message)
    local msg_id = pb:MsgId(msg_id_name);
    local data   = pb:Encode(msg_name, message);
    if not msg_id then 
        Log:Crit("msg_id is nil");
        return;
    end

    if not data then
        Log:Crit("data is nil");
        return ;
    end
    self:SendBinary(msg_id, data);
end

-- special send.
function LRole:Send(msg_name, message)
    local msg_id_name = string.gsub(msg_name .. "_id", "SProtoSpace.", "");
    self:SendMessage(msg_id_name, msg_name, message);
end

-- save info.
function LRole:Save()
    local sql = BuildString("insert into test.role(charid, account, name) values(", 
    self.m_uuid, ", '", self.m_account, "', '", self.m_name, "') ON DUPLICATE KEY update account ='", 
    self.m_account, "'");
    local r = MYSQL:Async_update(sql, self.m_uuid % MAIN_MYSQL_COUNT, function(ret, err) -- aysnc update.
        if ret then
            Log:Crit("save me ok");
        else
            Log:Crit("save me fail: " .. err);
        end
    end);
end

function LRole:DoRelease()
    Log:Crit("I am released");
    rolemgr:Release(self);
end

function LRole:OnExit()
    self:Save();
    self.m_state = 0;

    -- delay to release.
    Timer:AddTimer(2 * 1000, 0, function(para)
        if self.m_state == 0 then
            self:DoRelease();
        end
    end);
end

function LRole:OnConnected()
    --[[
    local id = Timer:AddTimer(5 * 1000, 1, function(para)
        self:Save();
    end);
    AddTable(self.m_timers, id);
    --]]
end