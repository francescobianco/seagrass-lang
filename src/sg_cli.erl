-module(sg_cli).
-export([main/1]).

main(["compile" | Args]) ->
    {File, Opts} = parse_compile_args(Args),
    case sg_compiler:compile_file(File, Opts) of
        {ok, Beam}      -> io:format("Compiled: ~s~n", [Beam]);
        {error, Reason} -> fail(Reason)
    end;

main(["run" | Args]) ->
    {File, _Opts} = parse_compile_args(Args),
    TmpDir = tmp_dir(),
    case sg_compiler:compile_file(File, [{outdir, TmpDir}]) of
        {ok, _Beam} ->
            true = code:add_path(TmpDir),
            Mod  = sg_compiler:filename_to_module(File),
            Mod:main([]);
        {error, Reason} ->
            fail(Reason)
    end;

main(["check" | Args]) ->
    {File, _Opts} = parse_compile_args(Args),
    case sg_compiler:inspect_file(File) of
        {ok, _AST, _Src} -> io:format("OK~n");
        {error, Reason}  -> fail(Reason)
    end;

main(["inspect" | Args]) ->
    {File, _Opts} = parse_compile_args(Args),
    case sg_compiler:inspect_file(File) of
        {ok, AST, ErlSrc} ->
            io:format("=== AST ===~n~p~n~n=== Generated Erlang ===~n~s~n",
                      [AST, ErlSrc]);
        {error, Reason} ->
            fail(Reason)
    end;

main(_) ->
    io:format(
        "Seagrass compiler v0.1~n"
        "Usage:~n"
        "  sgc compile <file.sg> [-o <outdir>]~n"
        "  sgc run     <file.sg>~n"
        "  sgc check   <file.sg>~n"
        "  sgc inspect <file.sg>~n"
    ),
    halt(1).

parse_compile_args([File | Rest]) ->
    Opts = parse_opts(Rest, []),
    {File, Opts};
parse_compile_args([]) ->
    io:format("Error: no input file~n"),
    halt(1).

parse_opts(["-o", Dir | Rest], Acc) -> parse_opts(Rest, [{outdir, Dir} | Acc]);
parse_opts([_ | Rest], Acc)         -> parse_opts(Rest, Acc);
parse_opts([], Acc)                  -> Acc.

fail({read_file, R}) ->
    io:format("Error reading file: ~p~n", [R]), halt(1);
fail({lex_error, F, L, M}) ->
    io:format("~s:~w: lexer error: ~s~n", [F, L, M]), halt(1);
fail({parse_error, F, L, M}) ->
    io:format("~s:~w: parse error: ~s~n", [F, L, M]), halt(1);
fail({erlang_compile, Errs}) ->
    [io:format("Erlang compile error: ~p~n", [E]) || E <- Errs], halt(1);
fail(Other) ->
    io:format("Error: ~p~n", [Other]), halt(1).

tmp_dir() ->
    Base = os:getenv("TMPDIR", "/tmp"),
    Dir  = filename:join(Base, "seagrass"),
    filelib:ensure_dir(filename:join(Dir, "x")),
    Dir.
