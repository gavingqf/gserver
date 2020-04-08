local net = net;
local common = common;

-- sessions manager.
local LSessions = {

}

-- create session.
function LSessions:create(session)
    if self[session] then return end

    -- get session info.
    local ip, port = common.get_session_info(session);
    local LSession = { -- new session.
        session = session,
        ip    = info.ip,
        port  = info.port,
        -- Send, GetIP, GetPort, GetSession function.
        Send  = function(self, msgid, data)
            net.client_send(self.session, msgid, data, #data);
        end,
        GetIP  = function(self) return self.ip end,
        GetPort = function(self) return self.port end,
        GetSession = function(self) return self.session end,
    };
    self[session] = LSession;
    return LSession;
end

-- get session.
function LSessions:get(session)
    return self[session];
end

-- remove.
function LSessions:remove(session)
    self[session] = nil;
end

return sessions;