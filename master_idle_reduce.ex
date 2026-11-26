defmodule MasterIdleReduce do
  def handle(state, pid) do
    IO.puts("THIS SHOULD ONLY RUN AT THE END WHEN ALL MAP TASKS ARE COMPLETE!!!!!!")



    IO.inspect(state.reduce_n_files, label: "REDUCED N FILES: ")








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
    state
  end
end
