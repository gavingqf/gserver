--
-- log module
-- asyncronous log and syncronous log(S)
--
local log = log;

-- log moudle.
local LogModule = {

};

function LogModule:Crit(c)
    log.crit(c);
end

function LogModule:SCrit(c)
    log.scrit(c);
end

function LogModule:Info(c)
    log.info(c);
end

function LogModule:SInfo(c)
    log.sinfo(c);
end

function LogModule:Warn(c)
    log.warn(c);
end

function LogModule:SWarn(c)
    log.swarn(c);
end

return LogModule;