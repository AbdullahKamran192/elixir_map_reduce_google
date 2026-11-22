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


          # map_results = Enum.map(file, fn f ->
          #   {:ok, result} = File.read(f)
          #   state.mapf.(f, result)
          # end)

          # joined_results = Enum.concat(map_results)


          # IO.inspect(joined_results, label: "THIS IS MY OUTPUT!!!")

          # joined_results

          #======================================================================

            {:ok, result} = File.read(file)
            output = state.mapf.(file, result)

          # output = state.mapf.("",file)

          # output = n.(file)

          IO.inspect(output, label: "THIS IS MY OUTPUT!!!")




          File.write("map_intermediate.txt", output)


          # TODO: add your code here
          # Don't forget to return state at the end


        # Reduce task from the master
        {:reduce, n, files} ->
          IO.puts("Got reduce task from master")
          # TODO: add your code here
          # Don't forget to return state at the end

      end

    run(state)
  end
end
