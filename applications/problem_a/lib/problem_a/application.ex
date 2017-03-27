defmodule ProblemA.Application do
  @moduledoc false

  alias ProblemA.{Alice, Bob, Data}

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(Data, []), worker(Alice, []), worker(Bob, [])]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end
end
