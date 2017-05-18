defmodule ProblemA do
  @moduledoc """
  ProblemA.
  """

  @doc """
  Start Agent with map as state.
  """
  def start_link(map) when is_map(map) do
    Agent.start_link(fn() -> map end)
  end

  @doc """
  Fetch a value from the agent.
  """
  def fetch!(agent, key) do
    res = Agent.get(agent, fn(state) ->
      try do
        Map.fetch!(state, key)
      rescue
        ex in KeyError ->
          {:error, ex}
      else
        value ->
          {:ok, value}
      end
    end)
    case res do
      {:ok, value} -> value
      {:error, ex} -> raise ex
    end
  end
end
