-module(repo_redis).

-behaviour(gen_server).

-compile([{parse_transform, lager_transform}]).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
        terminate/2, code_change/3]).

-define(IDENTIFIER, <<"{app_name}:facebook:{user_id}">>).

-record(state, {client}).

start_link() ->
    gen_server:start_link({local, repository}, ?MODULE, [], []).

init([]) ->
    % TODO: handle possible error coming from eredis
    % TODO: make init send gen_cast message to setup connection
    {ok, Client} = eredis:start_link(),
    {ok, #state{client=Client}}.

handle_call({access_token, {AppName, UserId}}, _From, #state{client=Client} = State) ->
    Identifier = identifier(AppName, UserId),
    lager:info("Identifier is: ~p", [Identifier]),
    [_, {ok, BCUserID}] = eredis:qp(Client, [["SELECT", 3], ["HGET", Identifier, "uuid"]]),
    [_, {ok, Data}] = eredis:qp(Client, [["SELECT", 0], ["GET", BCUserID]]),
    User = jsx:decode(Data),
    lager:info("user json is: ~p", [User]),
    Services = proplists:get_value(<<"services">>, User),
    Facebook = proplists:get_value(<<"facebook">>, Services),
    Token = proplists:get_value(<<"session">>, Facebook),
    {reply, Token, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{client=_Client} = _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
identifier(AppName, UserId) ->
    Bin = binary:replace(?IDENTIFIER, <<"{app_name}">>, AppName),
    Bin1 = binary:replace(Bin, <<"{user_id}">>, UserId),
    binary_to_list(Bin1).

-ifdef(TEST).
    -compile(export_all).
-endif.

