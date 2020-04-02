--
-- astar wraped by c
--
local cstar = cstart;

local astar_module = {
    module = nil,
};

function astar_module:new()
    local obj = {};
    self.__index = self;
    setmetatable(obj, self);
    return obj;
end

-- init or reset.
function astar_module:init()
    self.module = castar.new();
    return self.module ~= nil;
end
function astar_module:reset()
    if self.module ~= nil then
        self.module:release();
        self.module = nil;
    end
end

function astar_module:set_area_info(maxx, maxy)
    return self.module:set_area(maxx, maxy);
end

function astar_module:set_walkable(func)
    self.m_module:set_walkable(func);
end

-- find path：return true or false.
function astar_module:find_path(startx, starty, endx, endy)
    return self.m_module:find(startx, starty, endx, endy);
end

-- search path with walkable function.
-- return true or false.
function astar_module:search_path(startx, starty, endx, endy, func) 
    return self.m_module:search(startx, starty, endx, endy, func); 
end

-- return table or nil if not exist.
function astar_module:getpath()
    return self.module:get_path();
end


return astar_module