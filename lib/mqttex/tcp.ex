defmodule Mqttex.TCP do
	@moduledoc """
	This module provides network connectivity with Erlang's standard TCP libraries (i.e. `gen_tcp`).
	"""


	@doc """
	Starts a server socket at port `port` and connect it with the MQTT `server`. 
	"""
	def start_server(port // 1178) do
		{:ok, listen} = :gen_tcp.listen(port, [:binary, {:packet, 4},
											 {:reuseaddr, true},	
											 {:active, true}])
		:error_logger.info_msg("Mqttex.Server at port #{port} is listening\n")
		spawn(fn() -> spawn_server(listen) end)
	end

	defp spawn_server(listen) do
		{:ok, socket} = :gen_tcp.accept(listen)
		# :gen_tcp.close(listen)
		:error_logger.info_msg("Mqttex.Server accepted and spawning\n")
		spawn(fn() -> spawn_server(listen) end)
		loop(socket, :nil, Mqttex.Server)				
	end
	
	@doc """
	Starts a client socket connecting to `server` at `port`. The client process
	is `client`.
	"""
	def start_client(server, port, client) do
		{:ok, socket} = :gen_tcp.connect(server, port, [:binary, {:packet, 4}])
		loop(socket, client, Mqttex.Client)
	end
	

	@doc """
	Starts a new channel and returns its process id.
	"""
	def start_channel(Mqttex.Client.Connection[server: server, port: port] = con, client) do
		looper = fn() -> 
				{:ok, socket} = :gen_tcp.connect(server, port, [:binary, {:packet, 4}])
				loop(socket, client, Mqttex.Client)
			end
		Process.spawn_link(looper)
	end
	

	@doc """
	Socket loop
	"""
	def loop(socket, server, mod) do
		IO.puts("loop for #{inspect socket} and process #{inspect server} with module #{mod}")
		receive do
			{:tcp, ^socket, bin} ->
				IO.puts("Socket received binary = #{inspect bin}")
				str = :erlang.binary_to_term(bin)
				IO.puts("Socket (unpacked) #{inspect str}")
				# call the server
				case str do
					Mqttex.ConnectionMsg[] = con -> 
						do_connect(socket, con, mod)
					_ ->
						mod.receive(server, str)
						loop(socket, server, mod)
				end
			{:tcp_closed, ^socket} ->
				IO.puts("Socket #{inspect socket} closed")
			msg ->
				IO.puts("Socket sends message #{inspect msg}")
				:gen_tcp.send(socket, :erlang.term_to_binary(msg))
				loop(socket, server, mod)
		end
	end


	@doc """
	Start the server and sends the acknowledgement to the socket 
	(either with an error, closing the socket, or with the `:ok`) 
	"""
	def do_connect(socket, Mqttex.ConnectionMsg[] = con, mod) do
		case Mqttex.Server.connect(con, self) do
			{msg, server_pid} -> 
				send(self, msg)	
				loop(socket, server_pid, mod)
			error -> :gen_tcp.send(socket, :erlang.term_to_binary(error))
		end
	end

end