defmodule MasterDown do
  def handle(state, pid, reason) do
    IO.puts("worker #{inspect(pid)} is down")

    # If worker (pid) is down. we should check what in busy_workers list what file this worker was working on
    # and add the file back to the indexed_files and assign it to another worker.
    # Also i should delete intermediate files that belonged to that failed process and failed map task n. e.g. map_intermeidate_0_0_#PID0.140.0.txt and map_intermeidate_0_2_#PID0.140.0.txt

    IO.puts(
      "THIS IS WHAT BUSY WORKERS LOOKS LIKE WHEN TASK FAILED: #{inspect(state.busy_workers)}"
    )

    IO.puts("#{inspect(pid)} FAILED, we need to remove it from busy workers ")

    {task, updated_busy_workers} = Map.pop(state.busy_workers, pid)

    # if (Map.has_key?(state.mapped_files, task.index)) do
    #   IO.puts("THIS FILE IS ALREADY COMPLETED!!! WE RECEVIED DUPLICATES!!")
    # end

    case task do
      {:map, index, file} ->

        completed = Map.has_key?(state.mapped_files, index)

        state = if not completed do
          formatted_worker_pid = String.replace(inspect(pid), ["<", ">"], "")

          # iterate through all nR, with the same failed task index and PID, and delete all such files that exist.
          up_to = state.nR - 1
          Enum.map(0..up_to, fn reduce_n ->
            {:ok, removed_file} =
              File.rm_rf(
                "intermediate_map/map_intermediate_#{index}_#{reduce_n}_#{formatted_worker_pid}.txt"
              )

            IO.puts("Process #{inspect(pid)} removed the file #{removed_file}")
          end)


          # Remove the failed process(worker) from the busy_workers
          state = %{
            state
            | busy_workers: updated_busy_workers
          }




          # Next  and add the orignal file back to the indexed_files.
          # Try reassigning the work if idle_workers available
          state = if length(state.idle_workers) > 0 do
            [idle_worker | remaining_idle_workers] = state.idle_workers

            send(idle_worker, {:map, index, file, state.nR})
            Process.send_after(self(), {:straggled_task, idle_worker, index, file}, 5000)

            %{
              state
              | busy_workers: Map.put(state.busy_workers, idle_worker, {:map, index, file})
            }
          else
            # No available idle workers. # Only add file back to indexed_files, if it has not already been added by the receive straggler code.
            file_exists = List.keymember?(state.indexed_files, index, 0)

            if not file_exists do
              %{
                state
                | indexed_files: [{index, file} | state.indexed_files]
              }
            else
              state
            end
          end

          IO.inspect(state.indexed_files, label: "After the index file has been added back: ")

        else
          state
        end

      nil ->
        state
    end
  end
end
