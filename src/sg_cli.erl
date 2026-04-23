-module(sg_cli).
-export([main/1]).

main(["run" | Args]) ->
    {File, _Opts} = parse_args(Args),
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
    {File, _Opts} = parse_args(Args),
    case sg_compiler:inspect_file(File) of
        {ok, _AST, _Src} -> io:format("OK~n");
        {error, Reason}  -> fail(Reason)
    end;

main(["build" | Args]) ->
    {File, Opts} = parse_args(Args),
    OutDir = proplists:get_value(outdir, Opts, filename:dirname(File)),
    case sg_compiler:compile_file(File, [{outdir, OutDir}]) of
        {ok, Beam}      -> io:format("~s~n", [Beam]);
        {error, Reason} -> fail(Reason)
    end;

%% Developer shortcut — not in the public toolchain spec
main(["inspect" | Args]) ->
    {File, _Opts} = parse_args(Args),
    case sg_compiler:inspect_file(File) of
        {ok, AST, ErlSrc} ->
            io:format("=== AST ===~n~p~n~n=== Generated Erlang ===~n~s~n",
                      [AST, ErlSrc]);
        {error, Reason} ->
            fail(Reason)
    end;

main(_) ->
    io:format(
        "Seagrass ~s~n"
        "~n"
        "Usage:~n"
        "  sg run   <file.sg>            compile and execute~n"
        "  sg check <file.sg>            parse and validate only~n"
        "  sg build <file.sg> [-o <dir>] compile to .beam~n"
        "~n"
        "Developer:~n"
        "  sg inspect <file.sg>          print AST and generated Erlang~n",
        [version()]
    ),
    halt(1).

%% --------------------------------------------------------------------------

parse_args([File | Rest]) ->
    Opts = parse_opts(Rest, []),
    {File, Opts};
parse_args([]) ->
    io:format("sg: no input file~n"),
    halt(1).

parse_opts(["-o", Dir | Rest], Acc) -> parse_opts(Rest, [{outdir, Dir} | Acc]);
parse_opts([_ | Rest], Acc)         -> parse_opts(Rest, Acc);
parse_opts([], Acc)                  -> Acc.

fail({read_file, R}) ->
    io:format("sg: cannot read file: ~p~n", [R]), halt(1);
fail({lex_error, F, L, M}) ->
    io:format("~s:~w: ~s~n", [F, L, M]), halt(1);
fail({parse_error, F, L, M}) ->
    io:format("~s:~w: ~s~n", [F, L, M]), halt(1);
fail({erlang_compile, Errs}) ->
    [io:format("sg: internal compile error: ~p~n", [E]) || E <- Errs], halt(1);
fail(Other) ->
    io:format("sg: ~p~n", [Other]), halt(1).

tmp_dir() ->
    Base = os:getenv("TMPDIR", "/tmp"),
    Dir  = filename:join(Base, "seagrass"),
    filelib:ensure_dir(filename:join(Dir, "x")),
    Dir.

version() -> "v0.1.0".
