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

    IO.inspect(files, label: "INSPECTING FILES WITHIN Master.init()") # my code

    # files_progress = Enum.map(files, fn f -> {
    #   %{f: [mapped: false, reduced: false]}
    # end
    # })

    indexed_files = Enum.with_index(files, fn element, index ->
      {index, element}
    end)

    IO.inspect(indexed_files, label: "INDEXED FILES")

    state = %{
      parent: parent,
      indexed_files: indexed_files, # my code
      nR: nR,
      mapped_files: %{},
      reduced_files: %{},
      busy_workers: %{}
    }

    run(state)
  end


  def run(state) do
    state =
      receive do
        # idle worker handshake
        {:idle, pid} ->
          IO.puts("Got idle from worker #{inspect(pid)}: handshake")
          Process.monitor(pid)


          # REDUCE WORK:
          # All map tasks must be completed before reduce tasks begin. to do this i will check if indexed_files and busy_workers are empty.


          state = if length(state.indexed_files) == 0 and map_size(state.busy_workers) == 0 do
            IO.puts("THIS SHOULD ONLY RUN AT THE END WHEN ALL MAP TASKS ARE COMPLETE!!!!!!")
            send(pid, {:reduce, 1, ["intermediate_map/map_intermediate_0.txt","intermediate_map/map_intermediate_1.txt"]})

            [{index, mapped_file} | tail] = state.mapped_files

            send(pid, {:reduce, index, mapped_file})

            state = %{
              state
              | mapped_files: tail,
              busy_workers: Map.put(state.busy_workers, pid, {:reduce, index, mapped_file})
            }
            state
          else
            state
          end


          #========================================================


          # MAP WORK:
          # Check if files still exist in the indexed_files (meaning there is still unmapped files to be worked)

          state =
            if length(state.indexed_files) > 0 do

            IO.inspect(state.indexed_files, label: "INDEXED FILES FROM RUN()")
            [{index, file} | tail] = state.indexed_files

            IO.puts("INDEX #{index} AND ELEMENT #{file}")

            send(pid, {:map, index, file, state.nR})

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

          state

          # TODO: add your code here
          # Don't forget to return state at the end

        # map worker completes
        {:map, pid, n, files} ->
          IO.puts("Got map task complete from worker #{inspect(pid)}, n is #{n}. next inspect the file")

          IO.inspect(files, label: "The received files: ")


          {{:map, n, file}, remaining_busy_workers} = Map.pop(state.busy_workers, pid)

          IO.inspect(state.indexed_files, label: "AFTER POPPING: ")


          # if file == files do

          # end

          state = %{
            state
            | mapped_files: Map.put(state.mapped_files, n, file),
            busy_workers: remaining_busy_workers
          }


          IO.inspect(state.mapped_files, label: "Mapped files: ")
          IO.inspect(state.busy_workers, label: "busy_workers updated: ")


          state

        # reduce worker completes
        {:reduce, pid, n, file} ->
          IO.puts("Got reduce task complete from worker #{inspect(pid)}")
          # TODO: add your code here
          # Don't forget to return state at the end

        # failed worker
        {:DOWN, _, :process, pid, reason} ->
          IO.puts("worker #{inspect(pid)} is down")


          # If worker (pid) is down. we should check what in busy_workers list what file this worker was working on
          # and add the file back to the indexed_files and assign it to another worker.
          # Also i should delete intermediate files that belonged to that failed process and failed map task n. e.g. map_intermeidate_0_0_#PID0.140.0.txt and map_intermeidate_0_2_#PID0.140.0.txt

          {{:map, index, file}, updated_busy_workers} = Map.pop(state.busy_workers, pid)

          #We have the pid and map task n of the failed process. We can delete it's related intermediate mapped files


          formatted_worker_pid = String.replace(inspect(pid), ["<",">"], "")

          # iterate through all nR, with the same failed task index and PID, and delete all such files that exist.
          up_to = state.nR
          Enum.map(0..up_to, fn reduce_n ->
            {:ok, removed_file} = File.rm_rf("intermediate_map/map_intermediate_#{index}_#{reduce_n}_#{formatted_worker_pid}.txt")
            IO.puts("Process #{inspect(pid)} removed the file #{removed_file}")
          end)

          state

        end # receive

    run(state)
  end # run
end
# module
