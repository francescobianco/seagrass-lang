-module(sg_codegen).
-export([generate/2]).

generate({program, Stmts}, ModName) ->
    Exec     = [S || S <- Stmts, not is_import(S)],
    Body     = gen_stmts(Exec),
    ParBlock = case has_parallel(Exec) of
        true  -> "\n" ++ par_helper();
        false -> ""
    end,
    io_lib:format(
        "-module(~s).\n"
        "-export([main/1]).\n"
        "\n"
        "main(_Args) ->\n"
        "    ~s.\n"
        "~s",
        [atom_to_list(ModName), Body, ParBlock]
    ).

gen_stmts([])    -> "ok";
gen_stmts(Stmts) ->
    string:join([gen_stmt(S) || S <- Stmts], ",\n    ").

gen_stmt({seq_stmt, Expr}) ->
    gen_expr(Expr);
gen_stmt({parallel, Exprs}) ->
    Funs = ["fun() -> " ++ gen_expr(E) ++ " end" || E <- Exprs],
    "sg_par([" ++ string:join(Funs, ", ") ++ "])".

%% io.print(X) → io:format("~s~n", [X])
gen_expr({call, io, print, Args}) ->
    ArgsStr = string:join([gen_arg(A) || A <- Args], ", "),
    "io:format(\"~s~n\", [" ++ ArgsStr ++ "])";
%% io.println is an alias
gen_expr({call, io, println, Args}) ->
    gen_expr({call, io, print, Args});
gen_expr({block, Stmts}) ->
    "begin\n        " ++ gen_stmts(Stmts) ++ "\n    end";
%% Generic Erlang call: mod.fun(args) → mod:fun(args)
gen_expr({call, Mod, Fun, Args}) ->
    ArgsStr = string:join([gen_arg(A) || A <- Args], ", "),
    atom_to_list(Mod) ++ ":" ++ atom_to_list(Fun) ++ "(" ++ ArgsStr ++ ")".

gen_arg({string,  V}) -> "\"" ++ binary_to_list(V) ++ "\"";
gen_arg({integer, V}) -> integer_to_list(V);
gen_arg({float,   V}) -> float_to_list(V, [{decimals, 10}, compact]);
gen_arg({var,     V}) -> atom_to_list(V).

is_import({import, _}) -> true;
is_import(_)           -> false.

has_parallel([])                   -> false;
has_parallel([{parallel, _} | _])  -> true;
has_parallel([_ | T])              -> has_parallel(T).

%% Inlined parallel runtime — emitted only when the source has parallel blocks.
%% Uses spawn_monitor: crashes in parallel branches propagate to the caller.
par_helper() ->
    "sg_par(Funs) ->\n"
    "    Monitors = [spawn_monitor(fun() -> F() end) || F <- Funs],\n"
    "    [receive\n"
    "        {'DOWN', Ref, process, Pid, normal} -> ok;\n"
    "        {'DOWN', Ref, process, Pid, Reason} -> error({parallel_failed, Reason})\n"
    "     end || {Pid, Ref} <- Monitors].\n".
