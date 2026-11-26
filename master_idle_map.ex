defmodule MasterIdleMap do
  def handle(state, pid) do
    if length(state.indexed_files) > 0 do
      IO.inspect(state.indexed_files, label: "INDEXED FILES FROM RUN()")
      [{index, file} | tail] = state.indexed_files

      IO.puts("PROCESS: #{inspect(pid)} has been assigned INDEX #{index} AND FILE #{file}")

      send(pid, {:map, index, file, state.nR})
      Process.send_after(self(), {:straggled_task, pid, index, file}, 5000)

      state = %{
        state
        | indexed_files: tail,
          busy_workers: Map.put(state.busy_workers, pid, {:map, index, file})
      }

      IO.inspect(state.busy_workers, label: "WHAT DOES BUSY WORKERS LOOK LIKE ")

      state
    else
      # If indexed_files is empty (no work available), then put the worker into the idle list.

      worker_is_idle = Enum.member?(state.idle_workers, pid)

      if worker_is_idle do
        state
      else
        %{
          state
          | idle_workers: [pid | state.idle_workers]
        }
      end
    end
  end
end
