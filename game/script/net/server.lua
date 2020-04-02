-- save server type and id manager.
-- include type and id pair.
local common = common

local LServers = {
};

-- add server.
function LServers:Add(server)
    local type = common.get_server_type(server);
    if not self[type] then self[type] = {} end
    
    local t = self[type];
    t[#t + 1] = server;
end

-- remove type id.
function LServers:Remove(type, id)
    local t = self[type];
    if not t then return end

    for i = 1, #t do
        if t[i] == id then
            t[i] = nil;
            return ;
        end
    end
end

-- remove all type list.
function LServers:RemoveAll(type)
    self[type] = nil;
end

-- find type server id.
function LServers:Find(type)
    local t = self[type];
    if not t then 
        return nil;
    else
        return t[1];
    end
end

-- find all type list.
function LServers:FindAll(type)
    return self[type];
end

return LServers;