-- sessions list
local sessions = {

}

function sessions:add(session)
    if self[session] then
        return ;
    end

    local ip, port = common.get_session_info(session);
    self[session] = {
        ip = info.ip,
        port = info.port,
    }
end

function sessions:get(session)
    return self[session];
end

function sessions:remove(session)
    self[session] = nil;
end

return sessions;