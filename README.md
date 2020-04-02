# === gserver note ===
A server framework with lua logic

This is a server framework, especially for game server, with lua language.
All lua libraries are included in common fold. 

This framework includes the following functions:  
1, TCP protocl which can listen, connect with client or inner servers with config(as game fold *.xml).   
2, httpserver interface for http protocol.  
3, High efficiency timer(time wheel).  
4, Mysql with Asynchronous and Synchronous interface.  
5, Redis interface.  
6, Log module with Asynchronous and Synchronous interface.  
7, Astar path finding for 2d game.  
8, Net builder packet tool with lua_protobuf, as you can choose google protobuf or other protocol format.   
9, Common utility functions such as ansi2utf, and utf2ansi, which are wrapped in utility.lua.  
In a word, you can find anything here for server programming(as game server).

All the above functions, the related interfaces or notes you can find in main.lua.  
This framework can be use in server, especially for game server. Any problems please send to gavingqf@126.com  
