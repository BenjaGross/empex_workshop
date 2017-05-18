defmodule ProblemA do
  @moduledoc """
  ProblemA.
  """

  @doc """
  Start a task that is run again if it crashes
  """
  def start_link(fun) do
    task = Supervisor.Spec.worker(Task, [fun], [restart: :transient])
    Supervisor.start_link([task], [strategy: :one_for_one, max_restarts: 1])
  end
end
