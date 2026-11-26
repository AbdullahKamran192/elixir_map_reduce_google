defmodule Worker do
  def init(mapf, reducef, hash, master) do
    state = %{
      mapf: mapf,
      reducef: reducef,
      hash: hash,
      master: master
    }

    send(master, {:idle, self()})
    run(state)
  end

  def run(state) do
    state =
      receive do
        # Map task from the master
        {:map, n, file, nR} ->
          WorkerMapTask.handle(state, n, file, nR)

        # Reduce task from the master
        {:reduce, n, files} ->
          WorkerReduceTask.handle(state, n, files)
      end

    run(state)
  end
end
