-module(simple).
-compile(export_all).
-import(lists, [reverse/1]).

start_link() ->
  start([cowboy_adapter]).

start([Mod]) ->
    Port = list_to_integer(os:getenv("PORT")),
    %Port = 1234,
    Z = Mod:start_link([{port, Port}, 
			{handler, fun handle_request/1}]),
    io:format("Server started with ~w on ~w~n",[Mod, Port]),
    receive
	after
	    infinity ->
		void
	end.

render(File) ->
  case file:read_file(File) of
    {ok, Data} -> markdown:conv(binary:bin_to_list(Data));
    {error, Reason} -> case Reason of
        enoent -> "The file \"" ++ File ++ "\" does not exist.";
        eacces -> "Missing permission for reading the file, or for searching one of the parent directories.";
        eisdir -> "The named file is a directory.";
        enotdir -> "A component of the file name is not a directory. On some platforms, enoent is returned instead.";
        enomem -> "There is not enough memory for the contents of the file.";
        _ -> "Unknown error."
      end
  end.

handle_request(R) ->
  Path = R:get(path),
  Args = R:get(args),
  io:format("Path=~p Args=~p~n",[Path, Args]),
  handle(Path, Args, R).

handle([], _, R) ->
  handle(["index.ehe"], [], R);

handle([File], _, R) ->
  Filepath = "pages/" ++ File,
  case filelib:is_file(Filepath) of 
    true  -> R:send_file(Filepath);
	  false -> R:send_data(html, R:pre({missing_file, File}))
  end;

handle(X, Args, R) ->
  R:send_data(html, "ok").
