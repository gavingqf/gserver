--[[
path finding class. change close list to map.
--]]
require "common.class"
require "common.vector"

local math_sin     = math.sin;
local math_cos     = math.cos;
local table_insert = table.insert;
local table_remove = table.remove;
local math_min     = math.min;
local math_abs     = math.abs;

-- 行走的8个方向
local eight_dir = {
    {1, 1},
    {1, 0},
    {1, -1},
    {0, 1},
    {0, -1},
    {-1, 1},
    {-1, 0},
    {-1, -1}
}

-- can new one.
local AStar = class();
AStar.init = function(self, map, x_size, y_size)
    self.startPoint = nil;
    self.endPoint   = nil;
    self.open_list  = nil;
    self.close_list = nil;

    self.map        = map 
    self.mapRows    = x_size
    self.mapCols    = y_size

    self.cost       = 10
    self.diag       = 14
end

-- clear
AStar.clear = function(self)
    self.startPoint = nil;
    self.endPoint   = nil;
    self.open_list  = nil;
    self.close_list = nil;
end

-- set start
AStar.set = function(self, startPoint, endPoint)
    self.startPoint = startPoint;
    self.endPoint   = endPoint;
    self.open_list  = {};
    self.close_list = {};
end

-- insert to a sorted array.
AStar._insert_open_list = function(self, node)
    local index = nil
    for i = 1, #self.open_list do
        local e = self.open_list[i]
        if e then
            if e.f > node.f then
                index = i
                break;
            end
        end
    end
    if not index then index = #self.open_list + 1 end
    table_insert(self.open_list, index, node)
end

-- -1 end point can not walk
-- can not find path is -2.
-- count out is -3;
-- 0 is ok
AStar.searchPath = function(self, path)
    if self.map:IfPosObstacle(self.endPoint.x, self.endPoint.y) then --or self.map[self.startPoint.x][self.startPoint.y] == 0 
        return -1
    end

    -- add open_list.
    local startNode = {x = self.startPoint.x, y = self.startPoint.y, g = 0, h = 0, f = 0}
    table_insert(self.open_list, startNode)

    -- boundary check.
    local check = function(x, y)
        if 1 <= x and x <= self.mapRows and 1 <= y and y <= self.mapCols then
            if not self.map:IfPosObstacle(x, y) or (x == self.endPoint.x and y == self.endPoint.y) then
                return true
            end
        end
        return false
    end

    local count = 128;
    local dir = eight_dir
    while #self.open_list > 0 and count > 0 do
        count = count - 1

        local node, index = self:getMinNode()
        -- whether is target node.
        if node.x == self.endPoint.x and node.y == self.endPoint.y then
            self:buildPath(node, path)
            return 0
        end

        -- line check.
        if self.map:CanPass(LVector(node.x, node.y, 0), LVector(self.endPoint.x, self.endPoint.y, 0)) then
            self.endPoint.father = node;
            self:buildPath(self.endPoint, path)
            return 0;
        end

        -- delete open_list index element.
        table_remove(self.open_list, index)

        for i = 1, #dir do -- eight directions.
            local x = node.x + dir[i][1]
            local y = node.y + dir[i][2]
            if check(x, y) then
                -- get current node from (x, y, node)
                local curNode = self:getFGH(node, x, y, (x ~= node.x and y ~= node.y))
                local openNode, openIndex = self:nodeInOpenList(x, y)
                local closeNode, closeIndex = self:nodeInCloseList(x, y)
                if not closeNode and not closeIndex then
                    if openNode and openIndex then
                        if openNode.g > curNode.g then
                            self.open_list[openIndex] = curNode
                        end
                    else
                        self:_insert_open_list(curNode);
                    end
                end
            end
        end

        -- insert close list.
        self.close_list[node.x * self.mapRows + node.y] = node;
    end

    -- find path.
    if count > 0 then
        return -2
    else
        return -3;
    end
end

-- get node(f, g, h).
AStar.getFGH = function(self, father, x, y, isdiag)
    local node = {}
    local cost = self.cost
    if isdiag then cost = self.diag end

    node.father = father
    node.x = x
    node.y = y
    node.g = father.g + cost
    node.h = self:diagonal(x, y)
    node.f = node.g + node.h
    return node
end

AStar.nodeInOpenList = function(self, x, y)
    for i = 1, #self.open_list do
        local node = self.open_list[i];
        if node and node.x == x and node.y == y then
            return node, i
        end
    end
    return nil, nil
end
AStar.nodeInCloseList = function(self, x, y)
    local index = x * self.mapRows + y
    local node = self.close_list[index]
    if node then
        return node, index
    else
        return nil, nil
    end
end

-- find first node that is not nil.
AStar.getMinNode = function(self)
    for i = 1, #self.open_list do
        if self.open_list[i] then
            return self.open_list[i], i
        end
    end
    return nil, nil;
end

-- build path.
AStar.buildPath = function(self, node, path)
    while node do
        table_insert(path, LVector(node.x, node.y, 0));
        node = node.father
    end
end

-- calc h value.
AStar.diagonal = function(self, x, y)
    local dx = math_abs(x - self.endPoint.x)
    local dy = math_abs(y - self.endPoint.y)
    local minD = math_min(dx, dy)
    local h = minD * self.diag + dx + dy - 2 * minD
    return h * self.cost
end

return AStar
