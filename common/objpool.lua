-- 
-- object(without uuid, just with a object id) pool class, which can fetch and release obj  from it.
-- desc: get an object, and set a unique id to it, then save it.

--[[ 
-- object pool
LObjPool = {
  self.m_start_id,  -- object start id.
  self.m_objects,   -- object id to oject id table.
  self.m_object,    -- object class.
};
--]]

LObjPool = class();
function LObjPool:Ctor(Object)
    self.m_start_id = 1; -- must from 1, not 0.
    self.m_objects = {};
    self.m_object  = Object;
end

-- fetch and add in list.
function LObjPool:FetchObj()
    if not self.m_object then return nil end

    local obj = self.m_object();
    if not obj then return nil end

    local id = self.m_start_id;
    obj:SetId(id);
    self.m_objects[id] = obj;

    -- increase id for next fetch.
    self.m_start_id = self.m_start_id + 1;
    return obj;
end

-- just remove it from list.
function LObjPool:ReleaseObj(Obj)
    if not Obj then return end
    local id = Obj:GetId();
    self.m_objects[id] = nil;
    if Obj.Uninit then
        Obj:Uninit();
    end
    Obj = nil;
end

function LObjPool:FindObj(ObjId)
    if not ObjId then return nil end
    return self.m_objects[ObjId];
end

function LObjPool:GetObjects()
    return self.m_objects;
end