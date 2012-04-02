-module(blog).

-include("./deps/yaws/include/yaws_api.hrl").
-include("./src/token.hrl").

-define(KEY, "").
-define(SECRET, "").

-compile(export_all).

box(Str) ->
    {'div',[{class,"box"}],
     {pre,[],Str}}.

out(Arg) -> 
  case Arg#arg.appmoddata of
    %% "" -> list(Arg);
    "login" -> signup(Arg);
    "account/info" -> account_info(Arg);
      _ ->
    {ehtml,
     [{p,[],
       box(io_lib:format("A = ~p~n A#arg.appmoddata = ~p~n"
                         "A#arg.appmod_prepath = ~p~n"
                         "A#arg.querydata = ~p~n",
                         [Arg, Arg#arg.appmoddata,
                          Arg#arg.appmod_prepath,
                          Arg#arg.querydata]))}]}
  end.

%% ROUTES

signup(_Arg) ->
  [{"oauth_token_secret", TokenSecret}, {"oauth_token", Token}] = dropbox:request_token(?KEY, ?SECRET),
  mnesia:transaction(fun() -> mnesia:write(#token{token=Token, tokensecret=TokenSecret}) end),
  [{_, Link}] = dropbox:authorize(?KEY, ?SECRET, Token, TokenSecret, "http://localhost:8888/blog/account/info"),
  {redirect, Link}.

account_info(Arg) ->
  [{"uid", _Uid}, {"oauth_token", Token}] = yaws_api:parse_query(Arg),
  {atomic,[#token{token = Token, tokensecret = TokenSecret}]} = mnesia:transaction(fun() -> mnesia:read(token, Token) end),
  [{"oauth_token_secret", TokenSecret2}, {"oauth_token", Token2}, {"uid", _Uid2}] = dropbox:access_token(?KEY, ?SECRET, Token, TokenSecret),
  _B = dropbox:account_info(?KEY, ?SECRET, Token2, TokenSecret2),

  %% C = json2:decode_string(B),
  Metadata = json2:decode_string(dropbox:metadata(?KEY, ?SECRET, Token2, TokenSecret2, "sandbox", "")),
  {ok, {struct, [_, _, _, _, _, _, _, {"contents", {array, Files}}, _]}} = Metadata,

  O = lists:map(fun(File) -> 
        {struct, [_, _, _, _, _, _, {"path", [_FacingSlash|Filename]}, _, _, _, _, _]} = File,
        markdown:conv(dropbox:file_get(?KEY, ?SECRET, Token2, TokenSecret2, "sandbox", Filename))
    end, Files),

  {ehtml, [{p, [], io_lib:format("Out=~p~n", [O])}]}.
