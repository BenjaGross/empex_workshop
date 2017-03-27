defmodule ProblemCTest do
  use ExUnit.Case
  doctest ProblemC

  test "async uses a monitor" do
    %ProblemC{ref: ref} = ProblemC.async(fn() -> 1 + 1 end)
    assert_receive {^ref, 2}
    assert_receive {:DOWN, ^ref, :process, _, :normal}
  end

  test "async uses a link" do
    Process.flag(:trap_exit, true)
    assert %ProblemC{ref: ref, pid: pid} = ProblemC.async(fn() -> 1 + 1 end)

    assert_receive {^ref, 2}
    assert_receive {:EXIT, ^pid, :normal}
  end

  test "await returns result" do
    task = ProblemC.async(fn() -> 1 + 1 end)
    assert ProblemC.await(task, 5000) == 2
  end

  test "await flushes monitor on result" do
    task = ProblemC.async(fn() -> 1 + 1 end)
    assert %ProblemC{ref: ref} = task
    assert ProblemC.await(task, 5000) == 2

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  @tag :capture_log
  test "await exits on exception" do
    Process.flag(:trap_exit, true)

    task = ProblemC.async(fn() -> raise "oops" end)
    assert {{%RuntimeError{message: "oops"}, [_|_]},
            {ProblemC, :await, [^task, 123]}} =
      catch_exit(ProblemC.await(task, 123))
  end

  test "await exits on timeout" do
    task = ProblemC.async(fn() -> :timer.sleep(:infinity) end)
    assert {:timeout, {ProblemC, :await, [^task, 123]}} =
      catch_exit(ProblemC.await(task, 123))
  end

  test "await flushes monitor on timeout" do
    task = ProblemC.async(fn() -> :timer.sleep(:infinity) end)
    assert %ProblemC{ref: ref} = task
    assert catch_exit(ProblemC.await(task, 123))

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  test "await exits on normal exit" do
    task = ProblemC.async(fn() -> exit(:normal) end)
    assert {:normal, {ProblemC, :await, [^task, 123]}} =
      catch_exit(ProblemC.await(task, 123))
  end

  test "yield returns result" do
    task = ProblemC.async(fn() -> 1 + 1 end)
    assert ProblemC.yield(task, 5000) == {:ok, 2}
  end

  test "yield flushes monitor on result" do
    task = ProblemC.async(fn() -> 1 + 1 end)
    assert %ProblemC{ref: ref} = task
    assert ProblemC.yield(task, 5000) == {:ok, 2}

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  @tag :capture_log
  test "yield returns exit on exception" do
    Process.flag(:trap_exit, true)
    task = ProblemC.async(fn() -> raise "oops" end)
    assert {:exit, {%RuntimeError{message: "oops"}, [_|_]}} =
      ProblemC.yield(task, 123)
  end

  test "yield returns nil on timeout" do
    task = ProblemC.async(fn() -> :timer.sleep(:infinity) end)
    assert ProblemC.yield(task, 123) == nil
  end

  test "yield can be used until result received" do
    task = ProblemC.async(fn() ->
      receive do
        :done ->
          :done
      end
    end)
    assert ProblemC.yield(task, 123) == nil
    assert ProblemC.yield(task, 123) == nil
    assert %ProblemC{pid: pid} = task
    send(pid, :done)
    assert ProblemC.yield(task, 123) == {:ok, :done}
  end

  test "yield does NOT flush monitor on timeout" do
    task = ProblemC.async(fn() -> :timer.sleep(:infinity) end)
    assert ProblemC.yield(task, 123) == nil

    assert %ProblemC{ref: ref} = task
    assert Process.demonitor(ref, [:flush, :info])
  end

  test "yield returns exit on normal exit" do
    task = ProblemC.async(fn() -> exit(:normal) end)
    assert ProblemC.yield(task, 123) == {:exit, :normal}
  end
end
