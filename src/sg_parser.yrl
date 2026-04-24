%% Seagrass LALR(1) parser
%%
%% Semantics:
%%   newline  = sequential separator (one stmt after the other)
%%   comma    = parallel separator at stmt level (spawn_link on BEAM)
%%   comma    = argument separator inside function calls (resolved by context)

Nonterminals
    program stmts newlines stmt import_targets parallel_group expr block args arg.

Terminals
    newline lparen rparen lbrace rbrace comma dot import ident string integer float.

Rootsymbol program.

program -> stmts : {program, '$1'}.

stmts -> stmt                : flatten_stmt('$1').
stmts -> stmts newlines stmt : '$1' ++ flatten_stmt('$3').

newlines -> newline          : ok.
newlines -> newlines newline : ok.

%% A stmt is an import declaration OR an expression group (seq/parallel).
stmt -> import import_targets : '$2'.

import_targets -> ident : [{import, v('$1')}].
import_targets -> import_targets comma ident : '$1' ++ [{import, v('$3')}].

stmt -> parallel_group :
    case '$1' of
        [Single] -> {seq_stmt, Single};
        Multi    -> {parallel, Multi}
    end.

parallel_group -> expr                      : ['$1'].
parallel_group -> parallel_group comma expr : '$1' ++ ['$3'].

%% Module.function(args)
expr -> ident dot ident lparen rparen :
    {call, v('$1'), v('$3'), []}.
expr -> ident dot ident lparen args rparen :
    {call, v('$1'), v('$3'), '$5'}.
expr -> block :
    '$1'.

block -> lbrace newlines stmts newlines rbrace :
    {block, '$3'}.
block -> lbrace newlines stmts rbrace :
    {block, '$3'}.
block -> lbrace stmts newlines rbrace :
    {block, '$2'}.
block -> lbrace stmts rbrace :
    {block, '$2'}.

args -> arg           : ['$1'].
args -> args comma arg : '$1' ++ ['$3'].

arg -> string  : {string,  v('$1')}.
arg -> integer : {integer, v('$1')}.
arg -> float   : {float,   v('$1')}.
arg -> ident   : {var,     v('$1')}.

Erlang code.

%% Extract the value from a token tuple {Type, Line} or {Type, Line, Value}.
v({_Type, _Line, Value}) -> Value;
v({_Type, _Line})        -> undefined.

flatten_stmt(Stmt) when is_list(Stmt) -> Stmt;
flatten_stmt(Stmt)                    -> [Stmt].
