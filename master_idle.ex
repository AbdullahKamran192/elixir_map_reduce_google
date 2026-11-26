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

    map_phase_complete =
      Enum.all?(state.original_indexed_files, fn {k, v} ->
        Map.has_key?(state.mapped_files, k)
      end)

    # Meaning not all files are completed and put into mapped_files. We still execute the map phase
    if not map_phase_complete do
      # MAP PHASE
      state =
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
          state
        end
    else
      # REDUCE PHASE
      IO.puts("THIS SHOULD ONLY RUN AT THE END WHEN ALL MAP TASKS ARE COMPLETE!!!!!!")

      # send(
      #   pid,
      #   {:reduce, 1,
      #    [
      #      "intermediate_map/map_intermediate_0.txt",
      #      "intermediate_map/map_intermediate_1.txt"
      #    ]}
      # )

      # [{index, mapped_file} | tail] = state.mapped_files

      # send(pid, {:reduce, index, mapped_file})

      # state = %{
      #   state
      #   | mapped_files: tail,
      #     busy_workers:
      #       Map.put(state.busy_workers, pid, {:reduce, index, mapped_file})
      # }
    end

    state
  end
end
