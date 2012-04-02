-module(simple_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

-include("./src/token.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
  mnesia:create_table(token, [{attributes, record_info(fields, token)}]),
  application:start(simple).

start(_StartType, _StartArgs) ->
    simple_sup:start_link().

stop(_State) ->
  mnesia:stop().
