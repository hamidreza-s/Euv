-module(euv).

-export([start/0]).
-export([init/0]).
-export([ping/1]).

-define(DRIVER_NAME, "euv").

-define(EUV_PING, 1).
-define(EUV_XXXX, 2).

start() ->
    PrivDir = case code:priv_dir(?MODULE) of
                  {error, bad_name} ->
                      EbinDir = filename:dirname(code:which(?MODULE)),
                      AppPath = filename:dirname(EbinDir),
                      filename:join(AppPath, "priv");
                  Path ->
                      Path
              end,
    case erl_ddll:load_driver(PrivDir, ?DRIVER_NAME) of
	ok ->
	    ok;
	{error, already_loaded} ->
	    ok;
	Error ->
	    exit({Error, could_not_load_driver})
    end,

    spawn(?MODULE, init, []).

init() ->
    register(?MODULE, self()),
    Port = open_port({spawn, ?DRIVER_NAME}, [binary]),
    loop(Port).

loop(Port) ->
    receive
	{call, Caller, Msg} ->
	    Port ! {self(), {command, encode(Msg)}},
	    receive
		{Port, {data, Data}} ->
		    Caller ! {result, decode(Data)}
	    end,
	    loop(Port)
    end.

call_port(Msg) ->
    ?MODULE ! {call, self(), Msg},
    receive
	{result, Result} ->
	    Result
    end.

ping(X) ->
    call_port({ping, X}).

encode({ping, X}) ->
    Body = term_to_binary(X),
    <<?EUV_PING, Body/binary>>.

decode(X) ->
    {ok, binary_to_term(X)}.
