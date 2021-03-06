--[[
    xml loader module.
]]
local xmlreader = xmlreader;

local xmlmodule = {
    module = nil,
};

function xmlmodule:Init()
    self.module = true;
    return true;
end

-- create new one.
function xmlmodule:new()
    local r = {};
    r.module = xmlreader.new();
    r.release = function(self) self.module = nil end;
    setmetatable(r, {__index = self});
    return r;
end

-- load xml file, succ return true, else return false.
function xmlmodule:Load(filename)
    return self.module:Load(filename);
end

-- find element. exist return true, else false.
function xmlmodule:FindElem(node)
    return self.module:FindElem(node);
end

-- enter node.
-- it should call FindElem() before this function.
function xmlmodule:IntoElem()
    return self.module:IntoElem();
end

-- out of node.
function xmlmodule:OutElem()
    return self.module:OutOfElem();
end

-- get node attrib.
-- return node value as string.
function xmlmodule:GetAttrib(node)
    return self.module:GetAttrib(node);
end

-- add elem 
function xmlmodule:AddElem(node)
    return self.module:AddElem(node);
end

-- set node and value in certain node.
function xmlmodule:SetAttrib(node, value)
    return xmlmodule:SetAttrib(node, value);
end

-- find and into node.
function xmlmodule:EnterElem(node)
    return self:FindElem(node) and self:IntoElem(node);
end

if not xmlmodule.module then
    xmlmodule:Init();
end
return xmlmodule;

-- usage as following:
--[[
    local xmlmodule = require "common.xml";
    local xml = xmlmodule:new();
    if xml:Load(file) == false 
        printf("load " .. file .. " error");
        return ;
    end
    
    if xml:FindElem("node") then
        xml:IntoElem("node");
    end

    local value = xml:GetAttrib("sub_node");
]]