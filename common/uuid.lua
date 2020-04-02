--
-- unique id.
--
local uuid = {
    m_high_id = 0,
    m_low_id  = 0,
}

function uuid:SetHighId(id)
    self.m_high_id = id;
end

function uuid:getuuid()
    local low = self.m_low_id;
    self.m_low_id = self.m_low_id + 1;
    return self.m_high_id * (2 ^ 32) + low;
end

return uuid;