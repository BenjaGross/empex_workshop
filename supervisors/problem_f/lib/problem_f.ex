defmodule ProblemF do
  @moduledoc """
  ProblemF.
  """

  alias __MODULE__.{Logger, Server}
  use Supervisor

  @doc """
  Start an Agent to hold account balance and GenServer that updates it.
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end

  @doc false
  def init(_) do
    logger = worker(Logger, [])
    server = worker(Server, [])
    supervise([logger, server], [strategy: :one_for_one])
  end

  ## Do not change code below

  defdelegate increment(int), to: Server

  defdelegate last_log(), to: Logger, as: :last

  defmodule Logger do
    @moduledoc false

    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def log(msg), do: GenServer.cast(__MODULE__, {:log, msg})

    def last(), do: GenServer.call(__MODULE__, :last)

    def init(_), do: {:ok, nil}

    def handle_cast({:log, msg}, _) do
      IO.puts :user, msg
      {:noreply, msg}
    end

    def handle_call(:last, _, last) do
      {:reply, last, last}
    end
  end

  defmodule Server do
    @moduledoc false

    use GenServer
    alias ProblemF.Logger

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def increment(int), do: GenServer.call(__MODULE__, {:increment, int})

    def init(_), do: {:ok, 0}

    def handle_call({:increment, int}, _, old) do
      new = old + int
      Logger.log("increment #{int} from #{old} to #{new}")
      {:reply, new, new}
    end
  end
end
