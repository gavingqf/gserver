-- server type
-- server id form: area-group-type-index
-- the followings are type enums.
-- pls don't change the value --
ServerType = {
    GAME_SERVER_TYPE     = 1,
    DB_SERVER_TYPE       = 2,
    GATE_SERVER_TYPE     = 3,
    LOGIN_SERVER_TYPE    = 4,
    CENTER_SERVER_TYPE   = 5,
    GLOBAL_SERVER_TYPE   = 6,
    NAME_SERVER_TYPE     = 7,
    -- add more here.
};

-- server type name.
function ServerType:get_server_name(server_type)
    if server_type == self.GAME_SERVER_TYPE then
        return "gameserver";
    elseif server_type == self.DB_SERVER_TYPE then
        return "dbserver";
    elseif server_type == self.GATE_SERVER_TYPE then
        return "gateserver";
    elseif server_type == self.LOGIN_SERVER_TYPE then
        return "loginserver"
    elseif server_type == self.CENTER_SERVER_TYPE then
        return "centerserver";
    elseif server_type == self.NAME_SERVER_TYPE then
        return "nameserver";
    else
        return "unkown";
    end
end

-- GLOBAL mysql connect info：
-- CONNECT HANDLE
MAIN_MYSQL_HANDLE = 1

-- CONNECT COUNT
MAIN_MYSQL_COUNT  = 3