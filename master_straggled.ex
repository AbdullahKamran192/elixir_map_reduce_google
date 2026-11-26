defmodule MasterStraggler do
  def handle(state, pid, index, file) do
    # check whether this attempt is still running
    # and whether task n is still not complete
    # Reassign now or mark it pending.

    completed = Map.has_key?(state.mapped_files, index)

    # the file should not be complete, meaning it should not exist inside of mapped_files.
    state =
      if Map.has_key?(state.busy_workers, pid) and not completed do
        if length(state.idle_workers) > 0 do
          [idle_worker | remaining_idle_workers] = state.idle_workers

          send(idle_worker, {:map, index, file, state.nR})
          Process.send_after(self(), {:straggled_task, idle_worker, index, file}, 5000)

          %{
            state
            | busy_workers: Map.put(state.busy_workers, idle_worker, {:map, index, file}),
            idle_workers: remaining_idle_workers
          }
        else
          # No available idle workers. Add file back to the front of indexed_files to be processed by next available worker.
          %{
            state
            | indexed_files: [{index, file} | state.indexed_files]
          }
        end
      else
        state
      end

    state
  end
end
