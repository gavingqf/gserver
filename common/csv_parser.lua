--csv parser 
local string = string
local table = table

-- trim left space  
local function trim_left(s)  
	return string.gsub(s, "^%s+", "");  
end  


-- trim right space  
local function trim_right(s)  
	return string.gsub(s, "%s+$", "");  
end  

-- parse one line  
local function parseline(line)
	local ret = {};

	-- keep the last field as a complete one
	local s = line .. ",";
	while (s ~= "") do 
		local v = "";  
		local tl = true;  
		local tr = true;  

		while (s ~= "" and nil == string.find(s, "^,")) do  
			if (string.find(s, "^\"")) then  
				local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  

				if (nil == vx) then  
					return nil;  
				end  

				if (v == "") then  
					tl = false;  
				end  

				v = v .. vx;  
				s = vz;  

				while (string.find(s, "^\"")) do  
					local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
					if(vx == nil) then  
						return nil;  
					end  

					v = v .. "\"" .. vx;  
					s = vz;  
				end  

				tr = true;  
			else 

				local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");  
				if (vx ~= nil) then  
					v = v .. vx;  
					s = vz;  
				else  
					v = v .. s;  
					s = "";  
				end
				tr = false; 
			end  
		end  

		if (tl) then v = trim_left(v); end  
		if (tr) then v = trim_right(v); end  

		ret[#ret + 1] = v;

		if (string.find(s, "^,")) then  
			s = string.gsub(s, "^,", "");  
		end
	end  

	-- if all is "", then return nil, to remove it
	for i = 1, #ret do
		if ret[i] ~= "" then
			return ret;
		end
	end

	ret = nil;

	return nil;
end

-- get all row content 
local function getRowContent(file)  
	local content;  

	local check = false;  
	local count = 0;
	while true do  
		local t = file:read();  
		if not t then  if count == 0 then check = true end  break end  

		if not content then  
			content = t;
		else  
			content = content .. t;  
		end  

		local i = 1;
		while true do
			local index = string.find(t, "\"", i); 
			if not index then break end  
			i = index + 1;
			count = count + 1;
		end  

		if count % 2 == 0 then check = true break end 
	end  

	if not check then  assert(1~=1) end  
	return content  
end  


-- load file 
function LoadCsv(fileName) 
	local ret = {};  

	local file = io.open(fileName, "r")  
	assert(file, "open " .. fileName .. " error");  
	if not file then
		return nil;
	end

	local content = {};  
	while true do  
		local line = getRowContent(file);
		if not line then break end 
		table.insert(content, line);
	end  

	for k,v in pairs(content) do
		local linetable = parseline(v);
		if linetable then
			ret[#ret + 1] = linetable;
		end
	end  

	file:close();  

	return ret;
end




