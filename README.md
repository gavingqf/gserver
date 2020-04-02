# === gserver note ===
a game framework with lua logic

This is a server framework, especially for game server, with lua language.
All lua libraries are included in common fold. 

This framework includes the following functions:  
1, TCP protocl which can listen, connect with client or inner servers with config.  
2, httpserver interface for http protocol.  
3, High effiency timer(time wheel).  
4, Mysql with Asynchronous and Synchroous interface.  
5, Redis interface.  
6, Log with Asynchronous and Synchroous interface.  
7, astar path finding for 2d game.  
8, net builder packet tool with lua_protobuf.  
9, common utility functions such as ansi2utf, and utf2ansi.  

All the above functions, the related interfaces or notes you can find in main.lua.  
This framework can be use in server, especially for game server. Any problems please send to gavingqf@126.com  
