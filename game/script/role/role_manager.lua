
--
-- role manager module.
--

local role_manager = {
    m_roles    = {},
    m_start_id = 1,
}

function role_manager:Create()
    local role = LRole();
    role:SetObjId(self.m_start_id);

    self.m_start_id = self.m_start_id + 1;
    self.m_roles[role:GetObjId()] = role;
    role:Init(); -- init
    return role;
end

function role_manager:Release(role)
    if not role then return end
    role:Release(); -- release.
    self.m_roles[role:GetObjId()] = nil;
end

function role_manager:Find(id)
    return self.m_roles[id];
end

function role_manager:SaveAll()
    for i = 1, #(self.m_roles) do
        self.m_roles[i]:Save();
    end
end

return role_manager;