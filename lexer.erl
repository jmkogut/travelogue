-module(lexer).
-export([document/2, forward_index/1, forward_index/2, sanitize/2]).

document(Name, Content) ->
    Stripped = test:stopwatch("Sanitizing "++Name, lexer, sanitize, [Name, Content]),
        %Stripped = sanitize(Content),

    Tokens = test:stopwatch("Mapping "++Name, string, tokens, [Stripped, " "]),
        %Tokens = string:tokens(Stripped, " "), % This is map
    
    io:format("     ~p tokens..~n", [length(Tokens)]),
    test:stopwatch("Reducing "++Name, lexer, forward_index, [Tokens]).
        %forward_index(Tokens). % This is reduce

% builds a token list for a document
forward_index(Tokens) ->
    forward_index([], Tokens).

forward_index(Index, Tokens) when length(Tokens) == 0 ->
    Index;

forward_index(Index, Tokens) ->
    [Token | Tail] = Tokens,
    
    % Figure out if we have this token yet
    case lists:any(fun({T, _V}) -> T == Token end, Index) of
        true -> % seen the token, increment one of the existing ones
            Indexed = lists:map(
                fun({T, V}) when T == Token ->
                    {T, V + 1};
                (R) ->
                    R
                end,
            Index);
        false -> % haven't seen, append one
            Indexed = [{Token, 1} | Index]
    end,

    forward_index(Indexed, Tail).


sanitize(_Name, Source) ->
    %{ok, RE_NotAllowed} = re:compile("[^a-z ]+"),
    %{ok, RE_WhiteSpace} = re:compile("\s+"),

    Lowered = string:to_lower(Source),
    %Alpha = re:replace(Lowered, RE_NotAllowed, "", [{return, list}]),
    %SaneSpace = re:replace(Alpha, RE_WhiteSpace, " ", [{return, list}]),

    Lowered.


