-- session info list.
local LClients = {
};



-- role is lua data.
function LClients:Add(session, role)
    if self[client_id] then return end

    -- any other info.
    self[session] = role;
end

function LClients:Remove(session) 
    self[session] = nil;
end

function LClients:Find(session)
    return self[session];
end

return LClients;