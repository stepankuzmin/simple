-module(simple).
-compile(export_all).

start_link() ->
    {ok, spawn(?MODULE, start, [])}.

start() ->
    Id = "embedded",
    GconfList = [{id, Id}],
    Docroot = "./tmp",
    %% Port = list_to_integer(os:getenv("PORT")),
    SconfList = [{port, 8888}, {servername, "localhost"}, {listen, {127,0,0,1}}, {docroot, Docroot}],
    {ok, SCList, GC, ChildSpecs} = yaws_api:embedded_start_conf(Docroot, SconfList, GconfList, Id),
    [supervisor:start_child(simple_sup, Ch) || Ch <- ChildSpecs],
    yaws_api:setconf(GC, SCList),
    {ok, self()}.
