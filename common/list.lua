-- 
-- lua list class.
--

--require "common.class"

--[[
    LValueLink = {
        self.m_data;  -- data
        self.m_next;  -- next.
    };

    LList = {
    self.m_head;      -- head node(LValueLink)
    self.m_tail;      -- tail node.
    self.m_size;      -- total size.
  }
--]]

LValueLink = class();
function LValueLink:Ctor(value)
    self.m_next = nil;
    self.m_data = value;
end
function LValueLink:SetData(value)
    self.m_data = value;
end
function LValueLink:GetData()
    return self.m_data;
end

function LValueLink:SetNext(next)
    self.m_next = next;
end
function LValueLink:GetNext()
    return self.m_next;
end

--
-- list class.
--
LList = class();
function LList:Ctor()
   self.m_head = LValueLink();
   self.m_tail = self.m_head;
   self.m_size = 0; 
end

-- size
function LList:size()
    return self.m_size;
end

-- clear data.
function LList:clear()
    self.m_head:SetNext(nil);
    self.m_tail = self.m_head;
    self.m_size = 0;
end

-- replace s to d.
function LList:replace(s, d)
    local find = false;
    local link = self.m_head:GetNext();
    while link do
        if link:GetData() == s then
            link:SetData(d);
            find = true;
        end
        link = link:GetNext();
    end
    return find;
end

-- get back
function LList:back()
    if self.m_tail ~= self.head then
        return self.m_tail:GetData();
    else
        return nil;
    end
end

-- push back
function LList:push_back(data)
    local p = LValueLink(data);
    self.m_tail:SetNext(p);
    self.m_tail = p;
    self.m_size = self.m_size + 1;
end

-- get front
function LList:front()
    local link = self.m_head:GetNext();
    if link then
        return link:GetData();
    else
        return nil;
    end
end

-- succ return true, else return false.
function LList:pop_front()
    local link = self.m_head:GetNext();
    if link then
        if self.m_tail == link then -- if it is last one?
            self.m_tail = self.m_head;
        end
        self.m_head:SetNext(link:GetNext());
        self.m_size = self.m_size - 1;
        if self.m_size < 0 then
            self.m_size = 0;
        end
        return true;
    else
        return false;
    end
end

-- find data, exist return true, else return false.
function LList:find(data)
    local link = self.m_head:GetNext();
    while link do
        if link:GetData() == data then
            return true;
        end
        link = link:GetNext();
    end
    return false;
end

-- add, excude the same value.
function LList:add(data)
    if not self:find(data) then
        self:push_back(data);
    end
end

-- remove, succ return true, else false.
function LList:remove(data)
    local link = self.m_head:GetNext();
    
    -- pre node
    local pre  = self.m_head;
    while link do
        if link:GetData() == data then
            local next = link:GetNext();
            if self.m_tail == link then
                self.m_tail = pre;
            end
            pre:SetNext(next);
            self.m_size = self.m_size - 1;
            if self.m_size < 0 then
                self.m_size = 0;
            end
            return true;
        end
        pre = link;
        link = link:GetNext();
    end
    return false;
end

-- build data.
function LList:build()
    local ret = {};
    for v in self:iterator() do
        ret[#ret+1] = v;
    end
    return ret;
end

function LList:traverse()
    for value in self:iterator() do
        print(value);
    end
    print("size:" .. self:size());
end

-- iterator.
function LList:iterator()
    local link = self.m_head;
    return function()
        link = link:GetNext();
        if not link then
            return nil;
        else
            return link:GetData();
        end
    end
end

function LList:min()
    local min = nil;
    for value in self:iterator() do
        if not min then
            min = value; 
        end
        
        if value < min then
            min = value;
        end
    end
    return min;
end

function LList:max()
    local max = math.maxinteger;
    for value in self:iterator() do
        if value > max then
            max = value;
        end
    end
    return max;
end

function LList:move(last)
    for v in last:iterator() do
        self:add(v);
    end
    last:clear();
end