local _class = {}

--[[
	usage:
	Derived = class(Base or nil, function(self, ...)

	end)
	.
	.

	define:
	function Derived:Func()
		-- can call super Func()
		self.super:Func();
	end

	create object:
	local d = Derived() or 
	local d = Derived.new()
	d:Func()
--]]

------------------------ start define class function --------------------
-- base is base class, and _ctor is construct function, gc is gc function.
function class(base, _ctor, gc)
	local child = {
		Ctor     = false,
		__base__ = base,
	}

	-- define base class and construct function.
	if not _ctor and type(base) == "function" then
		local ctor = base;
		child.Ctor = ctor;
		child.__base__ = nil
	elseif not base and type(_ctor) == "function" then
		child.Ctor = _ctor;
		child.__base__ = nil
    elseif _ctor and type(_ctor) == "function" then
        child.Ctor = _ctor;
		child.__base__ = base;
	end

	if not gc then gc = false end

	-- the onlye new function.
	local function _new(...)
		local o = {}; -- return object.
		local function create(c, ...)
			if c.__base__ then
				create(c.__base__, ...);
			end
			if c.Ctor then
				c.Ctor(o, ...); -- here is object, not c(c is class, o is object.).
			end
		end
        
		local function release(Class, Object)	
			local Release;
             Release = function (c)
                 if c.Dtor then
                     c.Dtor(Object);
                end

                if c.__base__ then
                    Release(c.__base__);
				end
			end
			Release(Class);
        end

		 -- only for 5.3 version.
		 -- directly set __gc field of the metatable for destructor of this object.
		 if gc then
			setmetatable(o, {
			    __index = _class[child],
			    __gc    = function (ins) release(child, ins) end
		    });
		 else
			setmetatable(o, {__index = _class[child]});
	     end

		-- create from child.
		create(child, ...);
		return o;
	end

	-- create instance, call all base Ctor function.
	child.new = function(...)
		return _new(...);
	end

	-- Declare a table to save intance member.
	local vtbl = {};
	vtbl.is_a = function(self, klass)
		local m = child;
		while m do 
			if m == klass then return true end
			m = m.__base__;
		end
		return false;
    end
	_class[child] = vtbl;

	-- support class() to create instance: __call
	-- set value to vtbl table.
	setmetatable(child, {
		__newindex = function(t, k, v) rawset(vtbl, k, v) end,
		__call     = function(class_tbl, ...) return _new(...) end 
	});

	-- find from base table if can not find a certain field(derivation).
	if child.__base__ then
		local function _index(t, k)
			if not k then return nil end

			if k == "super" then -- if super then return __base__ data;
				return _class[child.__base__]
			else
				local value = _class[child.__base__][k];
				vtbl[k] = value;
			    return value;
			end
		end
		setmetatable(vtbl, {__index = _index});
	end

	-- return table.
	return child;
end
--------------------- end of class define --------------------
