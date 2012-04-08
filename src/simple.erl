-module(simple).
-compile(export_all).

-include("./deps/yaws/include/yaws_api.hrl").
-include("./src/token.hrl").

-define(KEY, "").
-define(SECRET, "").

%% API
start_link() ->
    {ok, spawn(?MODULE, start, [])}.

start() ->
    Id = "embedded",
    GconfList = [{id, Id}],
    Docroot = "./priv/www",
    %% Port = list_to_integer(os:getenv("PORT")),
    SconfList = [{port, 8888}, {servername, "localhost"}, {listen, {127,0,0,1}}, {docroot, Docroot}, {appmods, [{"blog", simple}]}],
    {ok, SCList, GC, ChildSpecs} = yaws_api:embedded_start_conf(Docroot, SconfList, GconfList, Id),
    [supervisor:start_child(simple_sup, Ch) || Ch <- ChildSpecs],
    yaws_api:setconf(GC, SCList),
    {ok, self()}.

%% Appmod callback
out(Arg) -> 
  case Arg#arg.appmoddata of
    "login" -> signup(Arg);
    "account/info" -> account_info(Arg);
      _ -> {ehtml, [{p, [], io_lib:format("Arg=~p~n", [Arg])}]}
  end.

%% Routes callbacks
signup(_Arg) ->
  [{"oauth_token_secret", TokenSecret}, {"oauth_token", Token}] = dropbox:request_token(?KEY, ?SECRET),
  mnesia:transaction(fun() -> mnesia:write(#token{token=Token, tokensecret=TokenSecret}) end),
  {redirect, "https://www.dropbox.com/1/oauth/authorize?oauth_token=" ++ Token ++ "&oauth_callback=http://localhost:8888/blog/account/info"}.

account_info(Arg) ->
  [{"uid", _Uid}, {"oauth_token", Token}] = yaws_api:parse_query(Arg),
  {atomic,[#token{token = Token, tokensecret = TokenSecret}]} = mnesia:transaction(fun() -> mnesia:read(token, Token) end),
  [{"oauth_token_secret", TokenSecret2}, {"oauth_token", Token2}, {"uid", _Uid2}] = dropbox:access_token(?KEY, ?SECRET, Token, TokenSecret),
  dropbox:account_info(?KEY, ?SECRET, Token2, TokenSecret2),
  Metadata = json2:decode_string(dropbox:metadata(?KEY, ?SECRET, Token2, TokenSecret2, "sandbox", "")),
  {ok, {struct, [_, _, _, _, _, _, _, {"contents", {array, Files}}, _]}} = Metadata,

  O = lists:map(fun(File) -> 
        {struct, [_, _, _, _, _, _, {"path", [_FacingSlash|Filename]}, _, _, _, _, _]} = File,
        markdown:conv(dropbox:file_get(?KEY, ?SECRET, Token2, TokenSecret2, "sandbox", Filename))
    end, Files),

  {ehtml, [{p, [], io_lib:format("Out=~p~n", [O])}]}.
