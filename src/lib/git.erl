-module(git).
-export([clone/1, clone/2, pull/0, pull/1, status/0, status/1, current_branch/0, current_branch/1]).

clone(Repo) ->
    run(["git", "clone", Repo]).

clone(Repo, Dir) ->
    run(["git", "clone", Repo, Dir]).

pull() ->
    run(["git", "pull"]).

pull(Dir) ->
    run_in_dir(Dir, ["git", "pull"]).

status() ->
    run(["git", "status", "--short"]).

status(Dir) ->
    run_in_dir(Dir, ["git", "status", "--short"]).

current_branch() ->
    string:trim(run(["git", "branch", "--show-current"])).

current_branch(Dir) ->
    string:trim(run_in_dir(Dir, ["git", "branch", "--show-current"])).

run(Args) ->
    run_port(Args, undefined).

run_in_dir(Dir, Args) ->
    run_port(Args, Dir).

run_port(Args, Dir) ->
    PortSettings0 = [{args, tl(Args)}, exit_status, use_stdio, stderr_to_stdout, binary],
    PortSettings =
        case Dir of
            undefined -> PortSettings0;
            _ -> [{cd, Dir} | PortSettings0]
        end,
    Port = open_port({spawn_executable, os:find_executable(hd(Args))}, PortSettings),
    collect_port(Port, <<>>).

collect_port(Port, Acc) ->
    receive
        {Port, {data, Data}} ->
            collect_port(Port, <<Acc/binary, Data/binary>>);
        {Port, {exit_status, 0}} ->
            binary_to_list(Acc);
        {Port, {exit_status, Status}} ->
            error({git_command_failed, Status, binary_to_list(Acc)})
    end.
