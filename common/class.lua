local _class = {}; -- it is resonable to be as local?

--[[
	usage:
	Derived = class(Base or nil, function(self, ...)

	end)
	.
	.

	define:
	function Derived:Func()
		self.super:Func();
	end

	create object:
	local d = Derived() or 
	local d = Derived.new()
	d:Func()
--]]

------------------------ start define class function --------------------
-- base is base class, and _ctor is construct function, gc is gc function.
function class(base, _ctor)
	local c = { -- return c(class) table.
		Ctor     = false,
		__base__ = base,
	};

	-- define base class and construct function.
	if not _ctor and type(base) == "function" then
		local ctor = base;
		c.Ctor = ctor;
		c.__base__ = nil
	elseif not base and type(_ctor) == "function" then
		c.Ctor = _ctor;
		c.__base__ = nil
    elseif _ctor and type(_ctor) == "function" then
        c.Ctor = _ctor;
		c.__base__ = base;
	end

	-- the onlye new function: new() or class();
	local function _new(...)
		local o = {}; -- return object.
		local function create(C, ...)
			if C.__base__ then
				create(C.__base__, ...);
			end
			if C.Ctor then
				C.Ctor(o, ...); -- here is object, not c(c is class, o is object.).
			end
		end
		
		-- Class and its Object.
		local function release(Class, Object)
			local Release;
			Release = function (C)
                if C.Dtor then
                     C.Dtor(Object);
                end

                if C.__base__ then
                    Release(C.__base__);
				end
			end
			Release(Class);
        end

		-- set __index and __gc memta function.
		setmetatable(o, {
			__index = _class[c], --[[note: _class[c] = vtbl]]
			__gc    = function(ins) release(_class[c], ins) end -- here is _class[c], not c.
		});

		-- create from c.
		create(c, ...);
		return o;
	end

	-- create instance, call all base Ctor function.
	c.new = function(...)
		return _new(...);
	end

	-- Declare a table to save intance member.
	local vtbl = {};
	vtbl.is_a = function(self, klass)
		local m = c;
		while m do 
			if m == klass then 
				return true;
			end
			m = m.__base__;
		end
		return false;
    end
	_class[c] = vtbl;

	-- support class() to create instance: __call
	-- set value to vtbl table. and set c.__base__ as its metatable.
	setmetatable(c, {
		__newindex = function(t, k, v) rawset(vtbl, k, v) end,
		__call     = function(class_tbl, ...) return _new(...) end 
	});

	-- find from base table if can not find a certain field(derivation).
	if c.__base__ then
		local function _index(t, k)
			if not k then return nil end

			if k == "super" then -- if super then return __base__ data;
				return _class[c.__base__];
			else
				local value = _class[c.__base__][k];
				vtbl[k] = value;
			    return value;
			end
		end
		setmetatable(vtbl, {__index = _index});
	end

	-- return c table.
	return c;
end
--------------------- end of class define --------------------

function resetclass(c)
	_class[c] = nil;
end