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

          #======================================================================

          {:ok, result} = File.read(file)
          output = state.mapf.(file, result)

          # output = state.mapf.("",file)

          # output = n.(file)

          IO.inspect(output, label: "THIS IS MY OUTPUT!!!")


          File.write("intermediate_map/map_intermediate_#{n}.txt", "")

          Enum.map(output, fn {k, v} ->
            File.write!("intermediate_map/map_intermediate_#{n}.txt", "{#{k},#{v}}\n", [:append])
          end)


          IO.puts("THE FILE HAS BEEN CREATED!!!")

          send(state.master, {:map, self(), n, "intermediate_map/map_intermediate_#{n}.txt"})

          #Process.sleep(3000)


          #send(state.master, {:idle, self()}) # Should the worker make sure the work was sent back to the master correctly before telling the master it's idle.


          state


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
