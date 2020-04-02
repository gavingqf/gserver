-- require "common.class"

local math = math;
local math_sqrt  = math.sqrt;
local math_atan2 = math.atan;
local math_ceil  = math.ceil;
local math_floor = math.floor;
local math_abs   = math.abs;
local math_exp   = math.exp;
local pi         = math.pi;
local math_sin   = math.sin;
local math_cos   = math.cos;
--
-- vector point class
--
--[[
self.m_x
self.m_y
self.m_z
--]]

-- const variables.
local degtorad = pi / 180;
local radtodeg = 180 / pi;
local ESP      = math_exp(-5);


-- return an angle 0 - 360
function GetAngle(angle)
    if angle < 0 then
        local num = math_floor(angle / 360);
        angle = angle + (num + 1) * 360;
    else
        local num = math_floor(angle / 360);
        angle = angle - num * 360;
    end
    return angle;
end

-----------------------------------------------------------------------------------------------------------------------------------------------
-- whether point is in circle(circlePoint, Radius)
function InCircle(CirclePoint, Radius, Point)
    local Distance = math_sqrt((CirclePoint.m_x - Point.m_x) * (CirclePoint.m_x - Point.m_x) + (CirclePoint.m_y - Point.m_y) * (CirclePoint.m_y - Point.m_y));
    if math_abs(Distance - Radius) < ESP then
        return 1;
    else
        if Distance > Radius then
            return 2;
        else 
            return 0;
        end
    end
end

-- whether point is in rectangle(startPoint, dx, dy)
function InRectangle(startPoint, dx, dy, Point)
    if not startPoint or not dx or not dy or not Point then
        return false;
    end

    return 
    startPoint:GetX() <= Point:GetX() and Point:GetX() <= startPoint:GetX()+dx and
    startPoint:GetY() <= Point:GetY() and Point:GetY() <= startPoint:GetY()+dy 
end

-- whether point is in sector.
function InSector(Radius, MinAngle, MaxAngle, CirclePoint, Point)
    local Distance = math_sqrt((Point.m_x - CirclePoint.m_x) * (Point.m_x - CirclePoint.m_x) + (Point.m_y - CirclePoint.m_y) * (Point.m_y - CirclePoint.m_y));
    local PointAngle = math_atan2(Point.m_x - CirclePoint.m_x, Point.m_y - CirclePoint.m_y) * radtodeg;
    if math_abs(MinAngle - PointAngle) < ESP or math_abs(MaxAngle - PointAngle) < ESP then
        if (Distance <= Radius) then
            return 1;
        else
            return 2;
        end
    else
        if PointAngle >= MinAngle and PointAngle <= MaxAngle then
            if math_abs(Distance - Radius) < ESP then
                return 1;
            elseif Distance <= Radius then
                return 0;
            else
                return 2;
            end
        else 
            return 2;
        end
     end
end

-- 计算叉乘 |P0P1| × |P0P2|
local function mult(a, b, c)
    return (a.m_x - c.m_x) * (b.m_y - c.m_y) - (b.m_x - c.m_x) * (a.m_y - c.m_y);
end

-- 判断线段是否包含点point
local function IsOnline(point, line)
    return ((math_abs(mult(line.pt1, line.pt2, point)) < ESP) and
        ((point.m_x - line.pt1.m_x) * (point.m_x - line.pt2.m_x) <= 0) and
        (( point.m_y - line.pt1.m_y ) * (point.m_y - line.pt2.m_y) <= 0) 
        );
end

-- aa, bb为一条线段两端点 cc, dd为另一条线段的两端点 相交返回true, 不相交返回false  
local function intersect(aa, bb, cc, dd)
   if math.max(aa.m_x, bb.m_x) < math.min(cc.m_x, dd.m_x)  then 
       return false;
   end

   if math.max(aa.m_y, bb.m_y) < math.min(cc.m_y, dd.m_y)  then 
       return false;  
   end

   if math.max(cc.m_x, dd.m_x) < math.min(aa.m_x, bb.m_x)  then 
       return false;  
   end 

   if math.max(cc.m_y, dd.m_y) < math.min(aa.m_y, bb.m_y)  then 
       return false;  
   end

   if mult(cc, bb, aa) * mult(bb, dd, aa) < 0 then 
       return false;  
   end

   if mult(aa, dd, cc) * mult(dd, bb, cc) < 0 then 
       return false;  
   end
   
   return true;  
end

-- 判断点在多边形内
function InPolygon(polygon, point)
    local count = 0;

    local line = {};
    line.pt2   = {};
    line.pt1   = point;
    line.pt2.m_y = point.m_y;
    line.pt2.m_x = -math.huge;

    for i = 1, i <= #polygon do
        -- 得到多边形的一条边
        local side = {};
        side.pt1 = polygon[i];
        side.pt2 = polygon[(i+1) % #polygon];

        if IsOnline(point, side) then
            return 1;
        end

        -- 如果side平行x轴则不作考虑
        if math_abs(side.pt1.m_y - side.pt2.m_y) > ESP then
           if IsOnline(side.pt1, line) then
                count = count + 1;
            elseif IsOnline(side.pt2, line)  then
                count = count + 1;
            elseif intersect(line.pt1, line.pt2, side.pt1, side.pt2) then
                count = count + 1;
            end

            if (count % 2 == 1) then
                return 0;
            else 
                return 2;
            end
        end
    end
end

-- pos is array table({x=?,y=?}), s is start index, e is end index.
-- src return table: s <= e, calc from e to s.
function GetLines(pos, s, e, src)
    -- whether s1, s2, s3 is in a line.
    -- si is {m_x = ?, m_y = ?} struct
    local function IsLine(s1, s2, s3)
	    if (s1.m_x == s2.m_x) then
		    return s2.m_x == s3.m_x;
	    else
		    if (s3.m_x == s2.m_x) then
			    return false;
		    else
			    return (s2.m_y - s1.m_y) * (s3.m_x - s2.m_x) == (s3.m_y - s2.m_y) * (s2.m_x - s1.m_x);
            end
	    end
    end


    if not pos or not src then
        return ;
    end
    
    if e < s then
        return ;
    end

    if e - s <= 1 then -- just add directly.
        for i = e, s, -1 do
            src[#src+1] = pos[i];
		end
    else
        local s1 = pos[e];
		local s2 = pos[e-1];
        src[#src+1] = s1;

		local index = e-2;
		while (index >= s and IsLine(s1, s2, pos[index])) do -- if it is a line, then continue.
			index = index-1;
        end
        -- recurse from tail.
        GetLines(pos, s, index + 1, src);
    end
end
------------------------------------------------------------------------------

 -- return dst pos from src->(dst, angle).
 function PolarProject(src, dist, angle)
     local dst = LVector(0, 0, 0);
     dst:SetX(math_ceil(src:GetX() + dist * math_cos(angle * degtorad)));
     dst:SetY(math_ceil(src:GetY() + dist * math_sin(angle * degtorad)));
     dst:SetZ(src:GetZ());
     return dst;
 end

 --================ LVector class====================--
 LVector = class(function(self, x, y, z)
     self.m_x = x or 1;
     self.m_y = y or 1;
     self.m_z = z;
 end)

 function LVector:SetX(x)
     self.m_x = x
 end
 function LVector:GetX()
     return self.m_x;
 end

 function LVector:SetY(y)
     self.m_y = y;
 end
 function LVector:GetY()
     return self.m_y;
 end

 function LVector:SetZ(z)
     self.m_z = z;
 end
 function LVector:GetZ()
     return self.m_z;
 end

 function LVector:Distance(to)
    if not to then return math.maxinteger end
    return math_sqrt((self.m_x - to.m_x) * (self.m_x - to.m_x) + (self.m_y - to.m_y) * (self.m_y - to.m_y));
 end

 function LVector:Distance2(to)
     return (self.m_x - to.m_x) * (self.m_x - to.m_x) + (self.m_y - to.m_y) * (self.m_y - to.m_y);
 end

 function LVector:Angle(to)
     return GetAngle(math_atan2(to.m_y - self.m_y, to.m_x - self.m_x) * radtodeg);
 end

 function LVector:__eq(rhs)
     return self.m_x == rhs.m_x and self.m_y == rhs.m_y and self.m_z == rhs.m_z;
 end

 function LVector:__add(pos)
     self.m_x = self.m_x + pos:GetX();
     self.m_y = self.m_y + pos:GetY();
     self.m_z = self.m_z + pos:GetZ();
 end

 function LVector:__sub(pos)
     self.m_x = self.m_x - pos:GetX();
     self.m_y = self.m_y - pos:GetY();
     self.m_z = self.m_z - pos:GetZ();
 end

 function LVector:__mul(rhs)
    return LVector(self.m_x * rhs, self.m_y * rhs, self.m_z * rhs);
 end

 function LVector:__div( rhs )
    return LVector(math_ceil(self.m_x / rhs), math_ceil(self.m_y / rhs), math_ceil(self.m_z / rhs));
 end
--===============LVector End====================--

--get line cross grids
function GetGrids(start_pos, end_pos, grids)
    if start_pos == end_pos then 
        return;
    end
    
    local function _check(x, y)
        if (start_pos:GetX()==x and start_pos:GetY()==y) or (end_pos:GetX()==x and end_pos:GetY()==y) then
            return false;
        else
            return true;
        end
    end

    local x0 = start_pos:GetX();
    local y0 = start_pos:GetY();
    local x1 = end_pos:GetX();
    local y1 = end_pos:GetY();

    local c0 = x0;
    local r0 = y0;
    local c1 = x1;
    local r1 = y1;

    local steep = math.abs(r1-r0) > math.abs(c1-c0);
    if steep then -- y差值更大, 交换下
        c0 = y0;
        r0 = x0;
        c1 = y1;
        r1 = x1;
    end

    if c0 > c1 then -- 起点在终点右侧，交换下
        local c0_tmp = c0;
        local r0_tmp = r0;
        c0 = c1;
        c1 = c0_tmp;
        r0 = r1;
        r1 = r0_tmp;
    end

    -- 此时的直线c0,r0（左下）  c1,r1（右上） 
    if c1 == c0 then
        if r0 > r1 then
            local tmp = 0;
            tmp = r0;
            r0 = r1;
            r1 = tmp; 
        end

        for i=r0, r1, 1 do
            if not steep and _check(c0, i) then
                grids[#grids + 1] = LVector(c0, i);
            elseif _check(i, c0) then
                grids[#grids + 1] = LVector(i, c0);
            end 
        end 
        return;
    end

    local ratio = math.abs((r1-r0)/(c1-c0))
    local mirror = 1;
    if r1 <= r0 then
        mirror = -1;
    end

    for col = c0, c1, 1 do
        local curr_r = r0 + mirror*ratio*(col-c0);
        local skip = false;

        if (col == c0) then
            skip = math.floor(curr_r) ~= r0;
        end

        if not skip then
            if not steep and _check(col, math.floor(curr_r)) then
                grids[#grids + 1] = LVector(col, math.floor(curr_r));
            elseif _check(math.floor(curr_r), col) then
                grids[#grids + 1] = LVector(math.floor(curr_r), col);
            end 
        end

        --根据斜率计算是否有跨格
        local flag = true;
        if mirror > 0 then
            flag = (math.ceil(curr_r) - curr_r) < ratio;
        else
            flag = (curr_r - math.floor(curr_r)) < ratio;
        end

        if flag then
            local cross_r = curr_r + mirror;
            if not (cross_r > r0 and cross_r > r1) or not (cross_r > c0 and cross_r > c1) then
                if not steep and _check(col, math.floor(cross_r)) then
                    grids[#grids + 1] = LVector(col, math.floor(cross_r));
                elseif _check(math.floor(cross_r), col) then
                    grids[#grids + 1] = LVector(math.floor(cross_r), col);
                end 
            end
        end
    end
end