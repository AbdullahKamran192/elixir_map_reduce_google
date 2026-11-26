defmodule MasterReduce do
  def handle(state, pid, n, file) do
    IO.puts("Got reduce task complete from worker #{inspect(pid)}")
  end
end
