-module(simple).
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

% returns html for given markdown file
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

handle([File], _, R) ->
  case filelib:is_file(File) of 
    true  -> R:send_file(File);
	  false -> R:send_data(html, R:pre({missing_file,File}))
  end;

handle(X, Args, R) ->
  R:send_data(html, R:pre({funny,X,Args})).
