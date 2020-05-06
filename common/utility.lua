--
--[[
	All common functions definition.
--]]

-- global function to localize.
local string_gsub   = string.gsub;
local package       = package;
local table         = table;
local table_insert  = table.insert;
local table_concat  = table.concat; 
local os            = os;
-- c export to lua space.
local common        = common;
local pb            = require "common/pb_module"
local log           = require "common/log_module"

-- mode: {colleage, step}
function gc_check(mode)
	collectgarbage(mode);
end

-- set and load proto file
function load_fold_proto(fold, proto)
	pb:Load_path(fold);
	pb:Load_file(proto);
	return true;
end

-- global variable check.
function global_variable_check()
	local mt = {
        __index = function(_, key)
            local info = debug.getinfo(2, "S")
            if info and info.what ~= "main" and info.what ~= "C" then
                log:Crit("visit a undefined variable: " .. key);
            end
            return rawget(_G, key);
		end,
        __newindex = function(_, key, value)
            local info = debug.getinfo(2, "S")
            if info and info.what ~= "main" and info.what ~= "C" then
                log:Crit("asign a undefined variable:" .. key);
            end
            return rawset(_G, key, value);
		end
    }
    setmetatable(_G, mt);
end

-- version.
if _VERSION ~= "Lua 5.1" then
	unpack = table.unpack;
else
	-- compatible with 5.1
	load = loadstring;
end

-- ansi to utf.
function ansi2utf(str)
	return common.ansi2utf(str);
end
-- utf to ansi
function utf2ansi(str)
	return common.utf2ansi(str);
end

-- add table t with value to end.
function AddTable(t, value)
    if not t or not value then
        return;
    end
    t[#t + 1] = value;
end

-- reload lua file
function Reload(szLuaFile)
	if not szLuaFile then
		return false;
	end
	
	-- replace / and \ to .
	string_gsub(szLuaFile, "//", ".");
	string_gsub(szLuaFile, "\\", ".");
    
	package.loaded[szLuaFile] = nil;
	return require(szLuaFile);
end

-- string split function
function Split(s, sep)
	local rt = {};
    string_gsub(s, '[^'..sep..']+', function(w) table_insert(rt, w) end );
    return rt
end

-- construct string, a high string cat function
function BuildString(...)
	local strs = {...};
	return table_concat(strs);	
end	

-- concat string with space.
function ConcatString(...)
	local strs = {...};
	return table_concat(strs, " ");
end

-- 打印错误信息
local function __TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6);
    print("---------------------------------------- TRACKBACK ----------------------------------------");
    print(track_text, "LUA ERROR");
    print("---------------------------------------- TRACKBACK ----------------------------------------");
    return false;
end

-- try call.
function trycall(func, ...)
    local args = {...}
    return xpcall(function() func(unpack(args)) end, __TRACKBACK__);
end

--install our crazy loader!
function InstallSpecialLoader()
    local loadfn = function(modulename)
        local errmsg = "";
        local modulepath = string.gsub(modulename, "%.", "/");
        for path in string.gmatch(package.path, "([^;]+)") do
            local filename = string.gsub(path, "%?", modulepath);
            filename = string.gsub(filename, "\\", "/");
            local result = loadfile(filename);
            if result then
               return result;
            end
            errmsg = errmsg .. "\n\t no file '" .. filename .. "' (checked with custom loader)";
        end
        return errmsg;   
	end
	
	-- lua5.1 loaders, but lua5.3 is searchers.
	local loaders = package.loaders or package.searchers
    table_insert(loaders, 1, loadfn);
end

-- global rand method.
function GetRand(min, max)
	max = max or min;
	local rand = common.rand or math.random;
	
	local real_min, real_max = min, max;
	if real_min > real_max then
		real_min, real_max = real_max, real_min;
	end

	if not real_min then
		return 0;
	elseif not real_max then
		if real_min > 0 then
			return rand(0, real_min);
		else
			return rand(real_min, 0);
		end
	else
		return rand(real_min, real_max);
	end
end

-- Rand pos(x, y), radius r.
function Rand(x, y, r)
	if r then
		x = x + GetRand(-r, r);
		y = y + GetRand(-r, r);
	end
	return x, y;
end

-- get tick count.
function GetTickCount()
	return common.get_tick_count();
end

-- exe path.
function GetExePath()
	return common.get_exe_path();
end

-- now time.
function GetNow()
	return common.now();
end

-- md5 string
function md5(content)
	return common.md5(content, #content);
end

-- build client head with size, return head string.
function build_client_head(size)
	size = size or 1;
	return common.build_client_head(size);
end

-- {probo}
-- return index.
function GetVecProbIndex(vec, prob_sum)
	prob_sum = prob_sum or 0;

	local sum = 0;
	local vec_sum = {};
	for i = 1, #vec do
		sum = sum + vec[i];
		vec_sum[i] = sum;
	end

	local real_sum = prob_sum;
	if prob_sum == 0 then
		real_sum = vec_sum[#vec_sum];
	else
		real_sum = prob_sum;
	end
	
	local rand_val = GetRand(1, real_sum);
	for i = 1, #vec_sum do
		if rand_val <= vec_sum[i] then
			return i;
		end
	end
	return #vec_sum;
end


-- {id, min, max, prob},
-- return index.
function GetProbIndex(prob_items, prob_sum)
	local vec_sum = {};
	for i = 1, #prob_items do
		vec_sum[i] = prob_items[i][4];
	end
	return GetVecProbIndex(vec_sum, prob_sum);
end

function GetProbIndexPro(prob_items, index, prob_sum)
	local vec_sum = {};
	for i = 1, #prob_items do
		vec_sum[i] = prob_items[i][index];
	end
	return GetVecProbIndex(vec_sum, prob_sum);
end

-- deep copy object.
function DeepCopy(object)
    local SearchTable = {}

    local function Func(object)
        if type(object) ~= "table" then
            return object
        end
        local NewTable = {}
        SearchTable[object] = NewTable
        for k, v in pairs(object) do
            NewTable[Func(k)] = Func(v)
	  end	  
        return setmetatable(NewTable, getmetatable(object))
    end
    return Func(object)
end

function table.invert(t)
	local invt = {}
	for k, v in pairs(t) do
		invt[v] = k
	end
	return invt
end

--Clamps a number between two values
function math.clamp(num, min, max)
	return num <= min and min or (num >= max and max or num)
end

function get_table_size(t)
	if type(t) == 'table' then
	    local c = 0;
	    for k, v in pairs(t) do
		    c = c + 1;
	    end
	     return c;
    else
	    return #t;
    end
end


