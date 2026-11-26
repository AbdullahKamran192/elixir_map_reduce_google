defmodule MasterMapComplete do
  def handle(state, pid, n, files) do
    IO.puts("Got map task complete from worker #{inspect(pid)}, n is #{n}. next inspect the file")

    IO.inspect(files, label: "The received files: ")

    {{:map, n, file}, remaining_busy_workers} = Map.pop(state.busy_workers, pid)

    file_already_completed = Map.has_key?(state.mapped_files, n)

    state =
      if not file_already_completed do
        # This is the first worker to complete the file(split). Add the split file to mapped_files.
        %{
          state
          | mapped_files: Map.put(state.mapped_files, n, file),
            busy_workers: remaining_busy_workers,
            idle_workers: [pid | state.idle_workers]
        }
      else
        # This file is already completed by earlier worker. Received Duplicate.
        # So, ignore the file, remove the worker from busy_workers and add to idle_workers.
        %{
          state
          | busy_workers: remaining_busy_workers,
            idle_workers: [pid | state.idle_workers]
        }
      end

    IO.inspect(state.indexed_files, label: "AFTER POPPING: ")

    IO.inspect(state.mapped_files, label: "Mapped files: ")
    IO.inspect(state.busy_workers, label: "busy_workers updated: ")

    state
  end
end
