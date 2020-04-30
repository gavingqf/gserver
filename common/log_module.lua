--
-- log module
-- asyncronous log and syncronous log(S)
--
local log = log;
local table_concat = table.concat;

-- log moudle.
local LogModule = {

};

--- concat all ... string.
local function concat(...)
    local strs = {...};
	return table_concat(strs);	
end

function LogModule:Crit(...)
    local c = concat(...);
    log.crit(c);
end

function LogModule:SCrit(...)
    local c = concat(...);
    log.scrit(c);
end

function LogModule:Info(...)
    local c = concat(...);
    log.info(c);
end

function LogModule:SInfo(...)
    local c = concat(...);
    log.sinfo(c);
end

function LogModule:Warn(...)
    local c = concat(...);
    log.warn(c);
end

function LogModule:SWarn(...)
    local c = concat(...);
    log.swarn(c);
end

return LogModule;