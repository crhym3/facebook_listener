-module(activity_fetcher).

-compile([{parse_transform, lager_transform}]).

-export([get_activities/0]).

get_activities() ->
    Address = "http://www.gazzetta.it",

    %% Handling only positive case, should we care for not successful requests?
    %% See how gcm-erlang handles this

    {ok, Result} = httpc:request(Address),
    {{_, 200, _}, _Headers, Body} = Result,


    %% For now I just log the title of a generic web page
    Title = extract_title(Body),
    lager:info("The webpage title is: ~p", [Title]).

    extract_title(Text) ->
    A = string:str(Text, "<title>"),
    B = string:str(Text, "</title>"),
    string:substr(Text, A+7, B-A-7).
