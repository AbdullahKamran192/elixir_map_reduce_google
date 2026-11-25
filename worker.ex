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

          #File.write("intermediate_map/map_intermediate_#{n}_#{reduce_n}_#{self()}.txt", "")

          formatted_worker_pid = String.replace(inspect(self()), ["<",">"], "")

          files_worked = Enum.reduce(sorted_output, %{}, fn {k,v}, acc ->
            reduce_n = state.hash.(k, nR)

            clear_or_append_file = if Map.has_key?(acc, reduce_n) do
              :append
            else
              :write
            end

            File.write!(
              "intermediate_map/map_intermediate_#{n}_#{reduce_n}_#{formatted_worker_pid}.txt",
              inspect({reduce_n, {k,v}}, printable_limit: :infinity) <> "\n",
              [clear_or_append_file, create_parents: true]
            )

            Map.put(acc, reduce_n, "intermediate_map/map_intermediate_#{n}_#{reduce_n}_#{formatted_worker_pid}.txt")

          end)

          IO.puts("THE FILE HAS BEEN CREATED!!!")

          IO.inspect(files_worked, label: "THESE FILES WRITTEN TO: ")

          # if n == 1 do
          #   raise("oops")
          # end


          send(state.master, {:map, self(), n, files_worked})

          Process.sleep(3000)

          # Should the worker make sure the work was sent back to the master correctly before telling the master it's idle.
          send(state.master, {:idle, self()})

          state

        # TODO: add your code here
        # Don't forget to return state at the end

        # Reduce task from the master
        {:reduce, n, files} ->
          IO.puts("Got reduce task from master")

          # We received multiple files

          read_content = Enum.map(files, fn f ->
            IO.inspect(f, label: "what is this file? ")
            {:ok, result} = File.read(f)
            #IO.inspect(result, label: "THIS WAS READ: ")
            result
          end)

          IO.inspect(read_content, label: "Read CONTENT REDUCE: ")



          # # sort the intermediate output by key. So that all values for a given key are together

          # sorted_intermediate = Enum.sort(intermediate)
          # ######################### IO.inspect(sorted_intermediate, label: "THE INTERMEDIATE")

          # # 2. Partition the sorted list into slices consisting of key/value pairs with the same key.

          # reduced_intermediate =
          #   Enum.reduce(sorted_intermediate, [], fn {k, v}, acc ->
          #     case acc do
          #       [] ->
          #         [{k, [v]}]

          #       [{last_k, last_vs} | rest] when last_k == k ->
          #         [{last_k, [v | last_vs]} | rest]

          #       _ ->
          #         [{k, [v]} | acc]
          #     end
          #   end)

          # # IO.inspect(reduced_intermediate, label: "reduced intermediates")

          # final_output =
          #   Enum.map(reduced_intermediate, fn {k, v} ->
          #     {k, reducef.(k, v)}
          #   end)

          # # output for the word count reducer
          # # [{"a", "3"}, {"b", "1"}]
          # sorted_output = Enum.sort(final_output)

          # # IO.inspect(sorted_output, label: "FINAL OUTPUT")

          # sorted_output_final = Enum.to_list(sorted_output)

          # sorted_output_final

          # # TODO: add your code here
          # # Don't forget to return state at the end
      end

    run(state)
  end
end
