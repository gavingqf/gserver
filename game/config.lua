--[[
    server config with lua.
]]

-- net config.
lower_server_config = {
    -- session parameters:
    session_init_size  = 16,
    session_grow_size  = 8,

    -- net send/recv buff parameters:
    net_send_buff_size = 128 * 1024,
    net_recv_buff_size = 128 * 1024,
    
}