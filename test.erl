-module(test).
-export([run/0, get_sources/0, forward_index/1, forward_index/2, file/1, file/0,
stopwatch/4]).

run() ->
    Files = stopwatch("Source Files", test, get_sources, []),
    ForwardIndexes = stopwatch("Indexing Files", test, forward_index, [Files]),
    ForwardIndexes.

stopwatch(Name, Module, Function, Params) ->
    io:format("-- ~s~n", [Name]),
    {Time, Return} = timer:tc(Module, Function, Params),
    io:format("-- ~s: ~fms~n", [Name, Time / 1000]),
    Return.

get_sources() ->
    {ok, Files} = file:list_dir('sources'),
    lists:map(fun(X) -> "sources/" ++ X end, Files).

forward_index(Files) ->
   forward_index([], Files).

forward_index(Index, Files)  when length(Files) == 0 ->
    Index;

forward_index(Index, Files) ->
    [File | Tail] = Files,

    {ok, Content} = file:read_file(File),
    io:format("    Indexing ~s [~w/~w]~n", [File, length(Index) + 1, (length(Index) + length(Files))]),
    Indexed = [{File, lexer:document(File, binary_to_list(Content))} | Index],

    forward_index(Indexed, Tail).

file() ->
    Files = ["sources/a.txt"],
    stopwatch("Opening file", test, forward_index, [Files]).

file(File) ->
    file:read_file(File).
