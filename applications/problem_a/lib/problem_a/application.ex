defmodule ProblemA.Application do
  @moduledoc false

  alias ProblemA.{Alice, Bob, Data}

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(Alice, []), worker(Bob, [])]
    opts = [strategy: :one_for_one]
    children= [worker(Data, []), supervisor(Supervisor, [children, opts])]
    Supervisor.start_link(children, [strategy: :one_for_all])
  end
end
