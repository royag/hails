package hails.client;

#if js
import hails.client.handler.ClientProgramJS;
typedef ClientProgram = ClientProgramJS;
#else
import hails.client.handler.ClientProgramServer;
typedef ClientProgram = ClientProgramServer;
#end

