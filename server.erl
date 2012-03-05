-module(server).
-compile(export_all).
-import(lists, [reverse/1]).

start([Mod]) ->
    Port = 1234,
    Z = Mod:start_link([{port, Port}, 
			{handler, fun handle_request/1}]),
    io:format("Server started with ~w~n",[Mod]),
    receive
	after
	    infinity ->
		void
	end.

handle_request(R) ->
  Path = R:get(path),
  Args = R:get(args),
  io:format("Path=~p Args=~p~n",[Path, Args]),
  handle(Path, Args, R).

handle([File], _, R) ->
  case filelib:is_file(File) of 
    true  -> R:send_file(File);
	  false -> R:send_data(html, R:pre({missing_file,File}))
  end;

handle(X, Args, R) ->
  R:send_data(html, R:pre({funny,X,Args})).
