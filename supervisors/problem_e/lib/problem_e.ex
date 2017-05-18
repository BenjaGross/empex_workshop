defmodule ProblemE do
  @moduledoc """
  ProblemE.
  """

  @doc """
  Start a Supervisor for Agents.
  """
  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    import Supervisor.Spec, warn: false
    {child_opts, sup_opts} = Keyword.split(opts, [:restart, :shutdown])
    supervise([worker(Agent, [], child_opts ++ [restart: :temporary])],
              [strategy: :simple_one_for_one] ++ sup_opts)
  end

  @doc """
  Start an Agent with a fun.
  """
  def start_child(sup, fun, opts \\ []) do
    Supervisor.start_child(sup, [fun, opts])
  end

  @doc """
  Start an Agent with module, function and arguments.
  """
  def start_child(sup, mod, fun, args, opts \\ []) do
    Supervisor.start_child(sup, [mod, fun, args, opts])
  end
end
