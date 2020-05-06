--
-- unique id.
--
local uuid = {
    m_high_id = 0,
    m_low_id  = 1,
}

function uuid:SetHighId(id)
    self.m_high_id = id;
end

-- uuid.
function uuid:getuuid()
    local low  = self.m_low_id;
    self.m_low_id = self.m_low_id + 1;
    return math.ceil(self.m_high_id * 4294967296 + low);
end

return uuid;