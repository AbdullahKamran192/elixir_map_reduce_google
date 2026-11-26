defmodule WorkerReduceTask do
  def handle(state, n, files) do
    IO.puts("Got reduce task from master")

    # We received multiple files

    read_content =
      Enum.map(files, fn f ->
        IO.inspect(f, label: "what is this file? ")
        {:ok, result} = File.read(f)
        # IO.inspect(result, label: "THIS WAS READ: ")
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
end
