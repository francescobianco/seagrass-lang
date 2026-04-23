-module(sg_compiler).
-export([compile_file/1, compile_file/2, filename_to_module/1, inspect_file/1]).

compile_file(File) ->
    compile_file(File, []).

compile_file(File, Opts) ->
    OutDir = proplists:get_value(outdir, Opts, filename:dirname(File)),
    case read_and_parse(File) of
        {ok, AST} ->
            ModName   = filename_to_module(File),
            ErlSource = sg_codegen:generate(AST, ModName),
            TmpErl    = tmp_erl(ModName),
            ok = file:write_file(TmpErl, ErlSource),
            CompileOpts = [debug_info, {outdir, OutDir}, return_errors],
            case compile:file(TmpErl, CompileOpts) of
                {ok, _Mod} ->
                    BeamPath = filename:join(OutDir, atom_to_list(ModName) ++ ".beam"),
                    {ok, BeamPath};
                {error, Errors, _Warnings} ->
                    {error, {erlang_compile, Errors}}
            end;
        {error, _} = Err ->
            Err
    end.

inspect_file(File) ->
    case read_and_parse(File) of
        {ok, AST} ->
            ModName   = filename_to_module(File),
            ErlSource = sg_codegen:generate(AST, ModName),
            {ok, AST, lists:flatten(ErlSource)};
        Err ->
            Err
    end.

filename_to_module(File) ->
    Base  = filename:basename(File, ".sg"),
    Safe  = lists:map(fun($-) -> $_; (C) -> C end, Base),
    list_to_atom(Safe).

%% --------------------------------------------------------------------------

read_and_parse(File) ->
    case file:read_file(File) of
        {ok, Bin} ->
            Source = binary_to_list(Bin),
            lex_and_parse(Source, File);
        {error, Reason} ->
            {error, {read_file, Reason}}
    end.

lex_and_parse(Source, File) ->
    case sg_lexer:string(Source) of
        {ok, Tokens, _EndLine} ->
            Filtered = strip_boundary_newlines(Tokens),
            case Filtered of
                [] -> {ok, {program, []}};
                _  ->
                    case sg_parser:parse(Filtered) of
                        {ok, AST} ->
                            {ok, AST};
                        {error, {Line, sg_parser, Msg}} ->
                            {error, {parse_error, File, Line, lists:flatten(Msg)}}
                    end
            end;
        {error, {Line, sg_lexer, Msg}, _} ->
            {error, {lex_error, File, Line, lists:flatten(Msg)}}
    end.

strip_boundary_newlines(Tokens) ->
    T1 = lists:dropwhile(fun({newline, _}) -> true; (_) -> false end, Tokens),
    lists:reverse(
        lists:dropwhile(fun({newline, _}) -> true; (_) -> false end,
                        lists:reverse(T1))
    ).

tmp_erl(ModName) ->
    Dir = tmp_dir(),
    filename:join(Dir, atom_to_list(ModName) ++ ".erl").

tmp_dir() ->
    Base = os:getenv("TMPDIR", "/tmp"),
    Dir  = filename:join(Base, "seagrass"),
    filelib:ensure_dir(filename:join(Dir, "x")),
    Dir.
