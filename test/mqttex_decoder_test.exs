defmodule MqttexQueueTest do
	@moduledoc """
	This test requires the Lossy Channel for checking that the protocols work for many 
	messages to send.
	"""
	require Lager
	use ExUnit.Case


	test "length one byte values" do
		numbers = [0, 100, 127]
		numbers |> Enum.each fn(n) -> 
			assert n == Mqttex.Decoder.binary_to_length(<<n>>, 4, fn() -> nil end)
		end
	end

	test "length 128 in one byte fails" do
		catch_error Mqttex.Decoder.binary_to_length(<<128>>, 4, fn() -> nil end)
	end

	test "length with two bytes" do
		bytes = %{ 0 => [0], 128 => [0x80, 0x01], 16_383 => [0xFF, 0x7F]}
		bytes |> Enum.each fn({n, bs}) ->
			assert n == Mqttex.Decoder.binary_to_length(<<hd bs>>, 4, fn () -> next_byte(tl bs) end)
		end 
	end

	test "length with three bytes" do
		bytes = %{ 0 => [0], 16_384 => [0x80, 0x80, 0x01], 2_097_151 => [0xFF, 0xFF, 0x7F]}
		bytes |> Enum.each fn({n, bs}) ->
			assert n == Mqttex.Decoder.binary_to_length(<<hd bs>>, 4, fn () -> next_byte(tl bs) end)
		end 
	end

	def next_byte([]), do: {nil, nil} 
	def next_byte([h | t]) do
		{<<h>>, fn() -> (next_byte(t)) end}
	end
	


end