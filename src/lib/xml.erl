-module(xml).
-export([parse/1, stringify/1]).

parse(Value) when is_binary(Value) ->
    parse(binary_to_list(Value));
parse(Value) when is_list(Value) ->
    {Doc, _Rest} = xmerl_scan:string(Value),
    Doc.

stringify(Value) when is_binary(Value) ->
    binary_to_list(Value);
stringify(Value) when is_list(Value) ->
    Value;
stringify(Value) when is_tuple(Value) ->
    lists:flatten(xmerl:export_simple([Value], xmerl_xml));
stringify(Value) ->
    lists:flatten(io_lib:format("~p", [Value])).
