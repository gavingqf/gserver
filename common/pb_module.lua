--
-- pb proto module.
--
local pb_module = {
    m_pbcodec = nil,
    m_init    = false,
}

function pb_module:Init()
    self.m_pbcodec = require "common.pbcodec";
    if not self.m_pbcodec then 
        return false;
    end
    
    self.m_init = true;
    return true;
end

function pb_module:Load_path(path)
    return self.m_pbcodec:add_pb_path(path);
end

function pb_module:Load_file(file)
    return self.m_pbcodec:load_file(file);
end

function pb_module:Encode(name, proto)
    return self.m_pbcodec:encode(name, proto);
end

function pb_module:Decode(name, data)
    return self.m_pbcodec:decode(name, data);
end

function pb_module:MsgId(msg_name)
    return self.m_pbcodec:enum("SProtoSpace.MsgId", msg_name);
end

function pb_module:Enum(enum_name, field_name)
    return self.m_pbcodec:enum(enum_name, field_name);
end

if not pb_module.m_init then 
    if not pb_module:Init() then
        print("pb module init error");
    end
end
return pb_module;