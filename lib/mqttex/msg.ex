defmodule Mqttex.Msg do
	defmodule Simple do
		@moduledoc """
		Defines all simple messages as structs. They contain at most a message id.
		"""
		defstruct msg_type: :reserved :: Mqttex.simple_message_type, 
			msg_id: 0 :: integer
	end
	
	@doc "Creates a new simple message of type `pub_ack`"
	def pub_ack(msg_id) when is_integer(msg_id), do: %Simple{msg_type: :pub_ack, msg_id: msg_id}

	@doc "Creates a new simple message of type `pub_rec`"
	def pub_rec(msg_id) when is_integer(msg_id), do: %Simple{msg_type: :pub_rec, msg_id: msg_id}

	@doc "Creates a new simple message of type `pub_comp`"
	def pub_comp(msg_id) when is_integer(msg_id), do: %Simple{msg_type: :pub_comp, msg_id: msg_id}

	@doc "Creates a new simple message of type `ping_req`"
	def ping_req(), do: %Simple{msg_type: :ping_req}

	@doc "Creates a new simple message of type `ping_resp`"
	def ping_resp(), do: %Simple{msg_type: :ping_resp}

	@doc "Creates a new simple message of type `disconnect`"
	def disconnect(), do: %Simple{msg_type: :disconnect}

	@doc "Creates a new simple message of type `unsub_ack`"
	def unsub_ack(msg_id) when is_integer(msg_id), do: %Simple{msg_type: :unsub_ack, msg_id: msg_id}

	defmodule ConnAck do
		@moduledoc """
		Define the `conn ack` message
		"""
		defstruct status: :ok :: Mqttex.conn_ack_type
	end

	@doc "Creates a new simple message of type `conn_ack`"
	def conn_ack(status \\ :ok), do: %ConnAck{status: status}
	


end
