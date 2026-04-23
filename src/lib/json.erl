-module(json).
-export([encode/1, decode/1]).

encode(Value) ->
    lists:flatten(encode_value(Value)).

decode(Value) when is_binary(Value) ->
    decode(binary_to_list(Value));
decode(Value) when is_list(Value) ->
    {Parsed, Rest} = parse_value(skip_ws(Value)),
    case skip_ws(Rest) of
        [] -> Parsed;
        Trailing -> error({invalid_json, trailing_input, Trailing})
    end.

encode_value(null) -> "null";
encode_value(true) -> "true";
encode_value(false) -> "false";
encode_value(Value) when is_integer(Value) ->
    integer_to_list(Value);
encode_value(Value) when is_float(Value) ->
    float_to_list(Value, [{decimals, 10}, compact]);
encode_value(Value) when is_binary(Value) ->
    encode_string(binary_to_list(Value));
encode_value(Value) when is_atom(Value) ->
    encode_string(atom_to_list(Value));
encode_value(Value) when is_map(Value) ->
    Pairs = [encode_string(key_to_list(Key)) ++ ":" ++ encode_value(Val)
             || {Key, Val} <- maps:to_list(Value)],
    "{" ++ string:join(Pairs, ",") ++ "}";
encode_value(Value) when is_list(Value) ->
    case is_string_like(Value) of
        true ->
            encode_string(Value);
        false ->
            "[" ++ string:join([encode_value(Item) || Item <- Value], ",") ++ "]"
    end.

key_to_list(Key) when is_binary(Key) -> binary_to_list(Key);
key_to_list(Key) when is_atom(Key) -> atom_to_list(Key);
key_to_list(Key) when is_list(Key) -> Key;
key_to_list(Key) -> lists:flatten(io_lib:format("~p", [Key])).

is_string_like([]) -> true;
is_string_like(List) ->
    lists:all(fun(Char) -> is_integer(Char) andalso Char >= 0 andalso Char =< 255 end, List).

encode_string(Text) ->
    "\"" ++ lists:flatten([escape_char(Char) || Char <- Text]) ++ "\"".

escape_char($") -> "\\\"";
escape_char($\\) -> "\\\\";
escape_char($\b) -> "\\b";
escape_char($\f) -> "\\f";
escape_char($\n) -> "\\n";
escape_char($\r) -> "\\r";
escape_char($\t) -> "\\t";
escape_char(Char) when Char < 32 ->
    lists:flatten(io_lib:format("\\u~4.16.0B", [Char]));
escape_char(Char) ->
    [Char].

skip_ws([Char | Rest]) when Char =:= $\s; Char =:= $\t; Char =:= $\n; Char =:= $\r ->
    skip_ws(Rest);
skip_ws(Rest) ->
    Rest.

parse_value([$" | Rest]) ->
    parse_string(Rest, []);
parse_value([$[ | Rest]) ->
    parse_array(skip_ws(Rest), []);
parse_value([${ | Rest]) ->
    parse_object(skip_ws(Rest), #{});
parse_value([$t, $r, $u, $e | Rest]) ->
    {true, Rest};
parse_value([$f, $a, $l, $s, $e | Rest]) ->
    {false, Rest};
parse_value([$n, $u, $l, $l | Rest]) ->
    {null, Rest};
parse_value([Char | _] = Input) when Char =:= $-; (Char >= $0 andalso Char =< $9) ->
    parse_number(Input);
parse_value(Other) ->
    error({invalid_json, unexpected_token, Other}).

parse_string([$" | Rest], Acc) ->
    {lists:reverse(Acc), Rest};
parse_string([$\\, Esc | Rest], Acc) ->
    parse_string_escape(Esc, Rest, Acc);
parse_string([Char | Rest], Acc) ->
    parse_string(Rest, [Char | Acc]);
parse_string([], _Acc) ->
    error({invalid_json, unterminated_string}).

parse_string_escape($", Rest, Acc) -> parse_string(Rest, [$" | Acc]);
parse_string_escape($\\, Rest, Acc) -> parse_string(Rest, [$\\ | Acc]);
parse_string_escape($/, Rest, Acc) -> parse_string(Rest, [$/ | Acc]);
parse_string_escape($b, Rest, Acc) -> parse_string(Rest, [$\b | Acc]);
parse_string_escape($f, Rest, Acc) -> parse_string(Rest, [$\f | Acc]);
parse_string_escape($n, Rest, Acc) -> parse_string(Rest, [$\n | Acc]);
parse_string_escape($r, Rest, Acc) -> parse_string(Rest, [$\r | Acc]);
parse_string_escape($t, Rest, Acc) -> parse_string(Rest, [$\t | Acc]);
parse_string_escape($u, [A, B, C, D | Rest], Acc) ->
    Codepoint = list_to_integer([A, B, C, D], 16),
    parse_string(Rest, [Codepoint | Acc]);
parse_string_escape(Esc, _Rest, _Acc) ->
    error({invalid_json, bad_escape, Esc}).

parse_number(Input) ->
    {Digits, Rest} = take_number(Input, []),
    Number = lists:reverse(Digits),
    case lists:member($., Number) orelse lists:member($e, Number) orelse lists:member($E, Number) of
        true -> {list_to_float(Number), Rest};
        false -> {list_to_integer(Number), Rest}
    end.

take_number([Char | Rest], Acc)
    when Char =:= $-; Char =:= $+; Char =:= $.; Char =:= $e; Char =:= $E;
         (Char >= $0 andalso Char =< $9) ->
    take_number(Rest, [Char | Acc]);
take_number(Rest, Acc) ->
    {Acc, Rest}.

parse_array([$] | Rest], Acc) ->
    {lists:reverse(Acc), Rest};
parse_array(Input, Acc) ->
    {Value, Rest0} = parse_value(Input),
    Rest = skip_ws(Rest0),
    case Rest of
        [$, | More] -> parse_array(skip_ws(More), [Value | Acc]);
        [$] | More] -> {lists:reverse([Value | Acc]), More};
        _ -> error({invalid_json, expected_array_separator, Rest})
    end.

parse_object([$} | Rest], Acc) ->
    {Acc, Rest};
parse_object([$" | Rest], Acc) ->
    {Key, Rest0} = parse_string(Rest, []),
    Rest1 = skip_ws(Rest0),
    case Rest1 of
        [$: | Rest2] ->
            {Value, Rest3} = parse_value(skip_ws(Rest2)),
            Rest4 = skip_ws(Rest3),
            case Rest4 of
                [$, | More] -> parse_object(skip_ws(More), Acc#{Key => Value});
                [$} | More] -> {Acc#{Key => Value}, More};
                _ -> error({invalid_json, expected_object_separator, Rest4})
            end;
        _ ->
            error({invalid_json, expected_colon, Rest1})
    end;
parse_object(Other, _Acc) ->
    error({invalid_json, expected_object_key, Other}).
