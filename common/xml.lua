--[[
    xml loader module.
]]
local xmlreader = xmlreader;

local xmlmodule = {
    module = nil,
};

function xmlmodule:Init()
    self.module = xmlreader.new();
    return self.module ~= nil;
end

-- create new one.
function xmlmodule:new()
    local r = {};
    setmetatable(r, {__index = self});
    return r;
end

-- load xml file, succ return true, else return false.
function xmlmodule:Load(filename)
    return self.module:Load(filename);
end

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
    return self.module:OutElem();
end

-- get node attrib.
-- return node value as string.
function xmlmodule:GetAttrib(node)
    return self.module:FindElem(node);
end

-- add elem 
function xmlmodule:AddElem(node)
    return self.module:AddElem(node);
end

-- set node and value in certain node.
function xmlmodule:SetAttrib(node, value)
    return xmlmodule:SetAttrib(node, value);
end

if not xmlmodule.module then
    xmlmodule:Init();
end
return xmlmodule;

-- usage as following:
--[[
    local xml = require "common.xml";
    if xml:Load(file) == false 
        printf("load " .. file .. " error");
        return ;
    end
    
    if xml:FindElem("node") then
        xml:IntoElem("node");
    end

    local value = xml:GetAttrib("sub_node");
]]