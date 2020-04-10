# === gserver introduce ===
A server framework with lua logic, which is platform independent.

This is a server framework, especially for game server, with lua language.
All lua libraries are included in common fold. 

**This framework includes the following functions:**  
  1, TCP protocl which can listen, connect with client or inner servers with config(as game fold *.xml).   
  2, httpserver interface for http protocol(for short connection http).   
  3, High efficiency timer(time wheel).  
  4, Mysql with Asynchronous and Synchronous interface.  
  5, Redis interface.  
  6, Log module with Asynchronous and Synchronous interface.  
  7, Astar path finding for 2d game.  
  8, Net builder packet tool with lua_protobuf, as you can choose google protobuf or other protocol format.   
  9, Common utility functions such as ansi2utf, and utf2ansi, which are wrapped in utility.lua. 

In a word, you can find anything here for server programming(especially for game server).

All the above functions, the related interfaces or notes you can find in main.lua.  
This framework can be use in server, especially for game server. Any problems please send to gavingqf@126.com  

If you want to see any examples, you can have a look at main.lua.  
If you wanto to known the mechanism of the low c++ engine which wraps the net, mysql, timer module, you can look at  
the ppt file.

**Thanks for the following code or web:**  
  1,lua5.3.  
  2,asio.    
  3,lua_protobuf.
