defmodule MasterIdle do
  def handle(state, pid) do
    state =
      if Map.has_key?(state.monitored_workers, pid) do
        state
      else
        ref = Process.monitor(pid)

        %{
          state
          | monitored_workers: Map.put(state.monitored_workers, pid, ref)
        }
      end

    IO.puts("Got idle from worker #{inspect(pid)}: handshake")

    remaining_idle_workers = List.delete(state.idle_workers, pid)

    state = %{
      state
      | idle_workers: remaining_idle_workers
    }

    IO.inspect(state.idle_workers, label: "IDLE WORKERS AT IDLE MASTER: ")


    map_phase_complete =
      Enum.all?(state.original_indexed_files, fn {index, file} ->
        Map.has_key?(state.mapped_files, index)
      end)

    # Meaning not all files are completed and put into mapped_files. We still execute the map phase
    if not map_phase_complete do
      # MAP PHASE
      state = MasterIdleMap.handle(state, pid)
    else
      # REDUCE PHASE
      state = MasterIdleReduce.handle(state, pid)
    end
  end
end
