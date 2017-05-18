defmodule ProblemB do
  @moduledoc """
  ProblemB.
  """

  use GenServer

  @doc """
  Start GenServer with map as state.
  """
  def start_link(map) when is_map(map) do
    GenServer.start_link(__MODULE__, map)
  end

  @doc """
  Fetch a value from the server.
  """
  def fetch!(server, key) do
    case GenServer.call(server, {:fetch!, key}) do
      {:ok, val} -> val
      {:error, ex} -> raise ex
    end
  end

  @doc false
  def init(map) do
    {:ok, map}
  end

  @doc false
  def handle_call({:fetch!, key}, _, state) do
    resp =
    try do
      Map.fetch!(state, key)
    rescue
      ex in KeyError ->
        {:error, ex}
    else
      value ->
        {:ok, value}
    end
    {:reply, resp, state}
  end
end
