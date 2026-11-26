defmodule Master do
  def start(files, nR) do
    spawn(Master, :init, [files, nR, self()])
  end

  def wait_until_done() do
    receive do
      m -> m
    end
  end

  def init(files, nR, parent) do
    # my code
    IO.inspect(files, label: "INSPECTING FILES WITHIN Master.init()")

    indexed_files =
      Enum.with_index(files, fn element, index ->
        {index, element}
      end)

    IO.inspect(indexed_files, label: "INDEXED FILES")

    list_to_nR = for n <- 0..nR - 1, do: n

    state = %{
      parent: parent,
      indexed_files: indexed_files,
      original_indexed_files: indexed_files,
      nR: nR,
      mapped_files: %{},
      reduced_files: %{},
      busy_workers: %{},
      monitored_workers: %{},
      idle_workers: [],
      reduce_n_files: Map.from_keys(list_to_nR, [])
    }

    run(state)
  end

  def run(state) do
    state =
      receive do
        # idle worker handshake
        {:idle, pid} ->
          MasterIdle.handle(state,pid)

        # map worker completes
        {:map, pid, n, files} ->
          MasterMapComplete.handle(state, pid, n, files)

        # reduce worker completes
        {:reduce, pid, n, file} ->
          MasterReduceComplete.handle(state, pid, n, file)

        # failed worker
        {:DOWN, _, :process, pid, reason} ->
          MasterDown.handle(state, pid, reason)

        {:straggled_task, pid, n, file} ->
          MasterStraggler.handle(state, pid, n, file)

      end

    # receive

    run(state)
  end

  # run
end

# module
