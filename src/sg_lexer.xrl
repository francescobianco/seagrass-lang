Definitions.
WHITESPACE = [\s\t\r]+
NEWLINE    = \n
COMMENT    = //[^\n]*
IDENT      = [a-zA-Z_][a-zA-Z0-9_]*
STRING     = \"[^\"]*\"
INTEGER    = [0-9]+
FLOAT      = [0-9]+\.[0-9]+

Rules.
{WHITESPACE}  : skip_token.
{COMMENT}     : skip_token.
{NEWLINE}     : {token, {newline, TokenLine}}.
\(            : {token, {lparen,  TokenLine}}.
\)            : {token, {rparen,  TokenLine}}.
,             : {token, {comma,   TokenLine}}.
\.            : {token, {dot,     TokenLine}}.
;             : {token, {newline, TokenLine}}.
import        : {token, {import,  TokenLine}}.
{FLOAT}       : {token, {float,   TokenLine, list_to_float(TokenChars)}}.
{INTEGER}     : {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
{STRING}      : {token, {string,  TokenLine, unquote(TokenChars)}}.
{IDENT}       : {token, {ident,   TokenLine, list_to_atom(TokenChars)}}.

Erlang code.
unquote(S) ->
    list_to_binary(lists:sublist(S, 2, length(S) - 2)).
