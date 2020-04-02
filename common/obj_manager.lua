--[[
    object(with uuid) manager class
]]

LObjectMap = class(function(self, object_class)
    self.m_objects = {};
    self.m_name_objects = {};
    self.m_obj_class = object_class;
end);

function LObjectMap:Release()
    self.m_objects = nil;
    self.m_obj_class = nil;
    self.m_name_objects = nil;
end

function LObjectMap:Create(id, name)
    local obj = self.m_objects[id];
    if obj then
        return obj;
    else
        obj = self.m_obj_class();
        assert(obj, "create object error");

        if obj.SetId then 
            obj:SetId(id);
        end

        if obj.SetName then
            obj:SetName(name);
        end

        self.m_objects[id] = obj;
        self.m_name_objects[name] = obj;

        return obj;
    end
end

function LObjectMap:Find(id)
    return self.m_objects[id];
end

function LObjectMap:FindName(name)
    return self.m_name_objects[name];
end

function LObjectMap:Release(obj)
    local id = obj:GetId();
    local name = obj:GetName();
    self.m_objects[id] = nil;
    self.m_name_objects[name] = nil;
end

function LObjectMap:Build()
    local ret = {};
    for _, v in pairs(self.m_objects) do
        ret[#ret+1] = v;
    end
    return ret;
end