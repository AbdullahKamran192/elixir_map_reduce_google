defmodule WorkerMapTask do
  def handle(state, n, file, nR) do
    IO.puts("Got map task from master")
    IO.inspect(file, label: "file ")
    IO.inspect(n, label: "n ")
    IO.inspect(nR, label: "nR ")

    # ======================================================================

    {:ok, result} = File.read(file)
    output = state.mapf.(file, result)

    # output = state.mapf.("",file)

    # output = n.(file)

    IO.inspect(output, label: "THIS IS MY OUTPUT!!!")

    # sort the output
    sorted_output = Enum.sort(output)

    # File.write("intermediate_map/map_intermediate_#{n}_#{reduce_n}_#{self()}.txt", "")

    formatted_worker_pid = String.replace(inspect(self()), ["<", ">"], "")

    files_worked =
      Enum.reduce(sorted_output, %{}, fn {k, v}, acc ->
        reduce_n = state.hash.(k, nR)

        clear_or_append_file =
          if Map.has_key?(acc, reduce_n) do
            :append
          else
            :write
          end

        File.write!(
          "intermediate_map/map_intermediate_#{n}_#{reduce_n}_#{formatted_worker_pid}.txt",
          inspect({reduce_n, {k, v}}, printable_limit: :infinity) <> "\n",
          [clear_or_append_file, create_parents: true]
        )

        Map.put(acc, reduce_n, [
          "intermediate_map/map_intermediate_#{n}_#{reduce_n}_#{formatted_worker_pid}.txt"
        ])
      end)

    IO.puts("THE FILE HAS BEEN CREATED!!!")

    IO.inspect(files_worked, label: "THESE FILES WRITTEN TO: ")

    # if n == 1 do
    #   raise("oops")
    # end

    if n == 1 do
      Process.sleep(6000)
    end

    send(state.master, {:map, self(), n, files_worked})





    # What happens if the last worker fails here. All other workers are idle. he sent complete to master
    # Master puts the file to mapped_file, removes this worker from busy workers and puts him into idle_workers. BUT HE FAILS HERE.
    # BEFORE SENDING THE IDLE MESSAGE.



    # ALSO in general, if a task finishes and sents a task complete message to master. the master will pop it from the busy_workers.
    # but if task fails here (instead of sending idle message, which ofcourse will add him back to busy workers), it will send :DOWN message.
    # master will execute pop process from busy_workers again. even though it's already popped.





    # Should the worker make sure the work was sent back to the master correctly before telling the master it's idle.
    send(state.master, {:idle, self()})

    state
  end
end
