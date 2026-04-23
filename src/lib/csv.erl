-module(csv).
-export([parse/1, stringify/1]).

parse(Value) when is_binary(Value) ->
    parse(binary_to_list(Value));
parse(Value) when is_list(Value) ->
    finalize_rows(parse_chars(Value, [], [], [], field, false)).

stringify(Rows) when is_list(Rows) ->
    string:join([stringify_row(Row) || Row <- Rows], "\n").

parse_chars([], Rows, Row, Field, _State, _Quoted) ->
    [lists:reverse(Field), lists:reverse(Row), Rows];
parse_chars([$" | Rest], Rows, Row, Field, field, false) ->
    parse_chars(Rest, Rows, Row, Field, quoted, true);
parse_chars([$" | Rest], Rows, Row, Field, quoted, true) ->
    case Rest of
        [$" | More] -> parse_chars(More, Rows, Row, [$" | Field], quoted, true);
        _ -> parse_chars(Rest, Rows, Row, Field, field, false)
    end;
parse_chars([$, | Rest], Rows, Row, Field, field, false) ->
    parse_chars(Rest, Rows, [lists:reverse(Field) | Row], [], field, false);
parse_chars([$\r, $\n | Rest], Rows, Row, Field, field, false) ->
    parse_chars(Rest, [lists:reverse([lists:reverse(Field) | Row]) | Rows], [], [], field, false);
parse_chars([$\n | Rest], Rows, Row, Field, field, false) ->
    parse_chars(Rest, [lists:reverse([lists:reverse(Field) | Row]) | Rows], [], [], field, false);
parse_chars([Char | Rest], Rows, Row, Field, State, Quoted) ->
    parse_chars(Rest, Rows, Row, [Char | Field], State, Quoted).

finalize_rows([Field, Row, Rows]) ->
    CompletedRow = lists:reverse([Field | Row]),
    CompletedRows =
        case CompletedRow of
            [[]] when Rows =:= [] -> [];
            _ -> [CompletedRow | Rows]
        end,
    lists:reverse(CompletedRows).

stringify_row(Row) ->
    string:join([stringify_field(Field) || Field <- Row], ",").

stringify_field(Field) when is_binary(Field) ->
    stringify_field(binary_to_list(Field));
stringify_field(Field) when is_integer(Field) ->
    integer_to_list(Field);
stringify_field(Field) when is_float(Field) ->
    float_to_list(Field, [{decimals, 10}, compact]);
stringify_field(Field) when is_atom(Field) ->
    stringify_field(atom_to_list(Field));
stringify_field(Field) when is_list(Field) ->
    NeedsQuotes =
        lists:any(fun(Char) -> Char =:= $, orelse Char =:= $\n orelse Char =:= $\r orelse Char =:= $" end, Field),
    Escaped = lists:flatten([escape_csv_char(Char) || Char <- Field]),
    case NeedsQuotes of
        true -> "\"" ++ Escaped ++ "\"";
        false -> Escaped
    end.

escape_csv_char($") -> "\"\"";
escape_csv_char(Char) -> [Char].
