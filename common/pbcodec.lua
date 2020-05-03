local _M = {}

--[[
  pb module wrapper.
]]

local pb = pb;
_M.pb = pb;
_M.pb.option("enum_as_value")

-- reset
function _M:reset()
    _M.pb.clear()
    package.loaded["protoc"] = nil
    _M.protoc = require("common.protoc")
    _M.protoc.reload()
    _M.protoc.include_imports = true
    _M.init = true;
end

-- add pb path
function _M:add_pb_path(tbl)
    for index, path in pairs(tbl) do
        _M.protoc.paths[index] = path
	end 
end

-- save proto key to value.
function _M:SaveToFile()
    local file = io.output("../starve-game/proto_dealer/proto.lua");
    if not file then
        print("produce proto.lua error");
        return ;
    end

    local c = "local proto = {";
    for name in self.pb.types() do
        -- name = .starve.
        local s, e = string.find(name, ".starve.");
        if s and e then
            c = c .. "\n";
            c = c .. "    ";
            local proto = string.sub(name, e+1);
            c = c .. proto .. "=" .. "\"" .. "starve." .. proto .. "\"";
            c = c .. ",";
        end
    end

    -- add tail.
    c = c .. "\n";
    c = c .. "};\n";
    c = c .. "return proto;";

    -- write and close.
    file:write(c);
    file:flush();
    file:close();
end

-- load pb
function _M:load_file(name)
    assert(self.protoc:loadfile(name))
end

-- tohex
function _M:toHex(bytes)
    print(self.pb.tohex(bytes))
end

-- find message
function _M:find_message(message)
    return self.pb.type("." .. message)
end

-- encode message
function _M:encode(message, data)
    if self:find_message(message) == nil then
        print("can not find " .. message);
        return ""
    end

    -- encode lua table data into binary format in lua string and return
    local bytes = assert(self.pb.encode(message, data))
    return bytes
end

-- decode message
function _M:decode(message, bytes)
    if self:find_message(message) == nil then
        print("can not find " .. message);
        return {}
    end

    -- decode the binary data back into lua table
    local data = assert(self.pb.decode(message, bytes))
    return data
end

-- enum value
function _M:enum(EnumTable, field_name)
    return pb.enum(EnumTable, field_name);
end

if not _M.init then _M:reset() end
return _M
