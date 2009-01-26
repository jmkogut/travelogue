%%%-------------------------------------------------------------------
%%% File    : indexer.erl
%%% Author  : Joshua Kogut <joshua.kogut@gmail.com>
%%% Description : 
%%%-------------------------------------------------------------------
-module(indexer).
-define(SERVER, ?MODULE).

-behaviour(gen_server).


%% Exports
-export([start_link/0, start/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([add_to_queue/1, process_queue/0, process_file/1]).

-define(INTERVAL, 5 * 1000). % Polls every 5 seconds
-define(CONTENT, "/home/joshua/Projects/travelogue/content/").


%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the server
%%--------------------------------------------------------------------
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
init(_Args) ->
    merle:connect(),
    {ok, []}.

%%--------------------------------------------------------------------
%% Function: %% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%%--------------------------------------------------------------------
handle_call({addlist, Filelist}, _From, State) ->
    State1 = lists:append(State, Filelist),
    {reply, done, State1};

handle_call({addfile, Filename}, _From, State) ->
    State1 = [Filename | State],
    {reply, {ok, "Added " ++ Filename}, State1};

handle_call(Request, _From, State) ->
  Reply = {not_found, Request},
  {reply, Reply, State}.

%%--------------------------------------------------------------------
%% Function: handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% Description: Handling cast messages
%%--------------------------------------------------------------------
handle_cast(process_queue, State) when length(State) == 0 ->
    %handle_cast(process_queue, State);
    {noreply, State};

handle_cast(process_queue, State) ->
    io:format("Processing queue (~w left)~n", [length(State)]),
    [File | Rest] = State,
    gen_server:cast(?SERVER, {process_file, File}),
    handle_cast(process_queue, Rest);


handle_cast({process_file, Filename}, State) ->
    io:format("Processing file: ~s~n", [Filename]),
    {ok, Content} = file:read_file(?CONTENT ++ Filename),
    Index = lexer:document(Filename, binary_to_list(Content)),
    set(Filename, Index),
    {noreply, State};
    

handle_cast(_Msg, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% Description: Handling all non call/cast messages
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: terminate(Reason, State) -> void()
%% Description: This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%%--------------------------------------------------------------------
terminate(Reason, _State) ->
  {terminated, Reason}.

%%--------------------------------------------------------------------
%% Func: code_change(OldVsn, State, Extra) -> {ok, NewState}
%% Description: Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%--------------------------------------------------------------------
%%% Generic Methods
%%--------------------------------------------------------------------
start() ->
    start_link().

add_to_queue({list, Filelist}) ->
    gen_server:call(?SERVER, {addlist, Filelist});

add_to_queue(Filename) ->
    gen_server:call(?SERVER, {addfile, Filename}).

process_queue() ->
    gen_server:cast(?SERVER, process_queue).

process_file(Filename) ->
    gen_server:cast(?SERVER, {process_file, Filename}).


%%--------------------------------------------------------------------
%%% Data access Methods
%%--------------------------------------------------------------------
set(Key, Value) ->
    merle:set(Key, Value).

getkey(Key) ->
    merle:getkey(Key).
