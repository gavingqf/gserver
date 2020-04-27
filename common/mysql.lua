--
-- wrap mysql module
--

local unpack = _G.unpack or table.unpack
local db     = db;
local common = common;
local Log    = require "common.log_module"
require "common.utility"


-- mysql execute result:
MysqlExecutevariable = {
    --未知错误: unknown error
    MYSQL_EXECUTE_UNKNOWN         = -5,

    --没法连接错误: connect error
    MYSQL_CONNECT_ERROR           = -4,

    -- 索引错误: index error
    MYSQL_EXECUTE_NO_INDEX        = -3,

    -- 参数错误: parameter error
    MYSQL_EXECUTE_PARA_ERROR      = -2,

    -- 执行结果错误: execute sql error
    MYSQL_EXECUTE_RESULT_FAIL     = -1,

    -- == 这个以上的表示出错,这个一下表示成功 == --
    -- == all above are errors, all the followings is succ == --

    -- 成功, result succ
    MYSQL_EXECUTE_RESULT_SUCC     = 0,

    -- 没有结果, without result
    MYSQL_EXECUTE_RESULT_WITHOUT_RES = 1,

    -- 有结果, has result return
    MYSQL_EXECUTE_RESULT_WITH_RES = 2,
};

--[[
    Async is Asyncronous interface, function(ret, err, ...) end: ret is bool.
    Sync  is Syncronous interface.  return ret is integer as MysqlExecutevariable table's value.
]]

--
-- mysql handle
-- index is handle line.
-- use must select a proper index(0, m_count - 1), if you ignore index, you can push nil value.
--

-- mysql connect module
local MysqlModule = {
    m_handle = nil, -- connect handle.
    m_count  = 1,   -- connect num.
}

-- you can create a new instance.
-- for another connection with mysql.
function MysqlModule:new(o)
    o = o or {};
    setmetatable(o, {__index = self});
    return o;
end


-- handle decide connection.
function MysqlModule:Init(handle, count)
    self.m_handle = handle or 1;
    self.m_count  = count or 1;
    if self.m_count <= 0 then
        return false;
    end
    return db.mysql_init();
end

-- wait to execute all sql.
-- this interfacel will block until all sql finished.
function MysqlModule:Wait()
    db.mysql_wait(self.m_count, self.m_handle);
end

--[[
    { ip, port, user, pass, database, charset },
    default charset is utf8
--]]
-- return true or false.
function MysqlModule:Connect(...)
    local args = {...};
    if #args == 0 then
        return false;
    elseif #args == 1 then
        if type(args[1] == 'table') then
            return self:ConnectTable(args[1]);
        else
            return false;
        end
    else
        return self:ConnectString(...);
    end
end

function MysqlModule:ConnectTable(connect_info)
    if #connect_info <= 5 then
        Log:Crit("connect para is so less");
        return false;
    end

    local charset = connect_info[6];
    -- default charset is utf8
    charset = charset or "utf8";

    local r, err = db.mysql_connect(self.m_handle,
      connect_info[1], connect_info[2], connect_info[3],
      connect_info[4], connect_info[5], charset, 
      self.m_count
    );
    if not r then
        Log:SCrit(BuildString("connect mysql return err: ", err));
    end

    return r;
end

-- connect detail
function MysqlModule:ConnectString(ip, port, user, pass, db, charset)
    return self:Connect({ip, port, user, pass, db, charset});
end

-- return return value, error string
function MysqlModule:Sync_update(sql, index)
    if not index then index = GetRand(0, self.m_count - 1) end
    return db.mysql_sync_query_no_res(self.m_handle, index, sql);
end

-- return ret(integer), error and results which is a table or nil
-- table format: : {{},...}
function MysqlModule:Sync_query(sql, index)
    if not index then index = GetRand(0, self.m_count - 1) end
    local ret, error, res = db.mysql_sync_query_with_res(self.m_handle, index, sql);
    return ret, error, res;
end

-- func: function(ret, err) end
-- ret is bool, err is error string.
function MysqlModule:Async_update(sql, index, func)
    if not func then
        Log:Crit("async update func is nil");
        return MysqlExecutevariable.MYSQL_EXECUTE_UNKNOWN, "func is nil";
    end
    if not index then index = GetRand(0, self.m_count - 1) end
    -- async execution.
    return db.mysql_async_query_no_res(self.m_handle, index, sql, func);
end

-- func: function(ret, err, res) end
-- ret bool
-- err error string
-- res result(table): {{},...}
function MysqlModule:Async_query(sql, index, func)
    if not func then
        Log:Crit("async update func is nil");
        return MysqlExecutevariable.MYSQL_EXECUTE_UNKNOWN, "func is nil";
    end
    if not index then index = GetRand(0, self.m_count - 1) end

    return db.mysql_async_query_with_res(self.m_handle, index, sql, func);
end

-- return nil or escape data.
function MysqlModule:Escape(data)
    if not data then return nil end
    return db.mysql_escape(self.m_handle, data);
end

-- mysql close
function MysqlModule:Close(group)
    db.mysql_close(group);
end

return MysqlModule;

