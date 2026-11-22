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

          # send(pid, {:map, 1, Enum.at(state.files, 0), state.nR})
          # state


          #========================================================

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


            # filter out the job just sent.


            state

          # TODO: add your code here
          # Don't forget to return state at the end

        # map worker completes
        {:map, pid, n, files} ->
          IO.puts("Got map task complete from worker #{inspect(pid)}")
          # TODO: add your code here
          # Don't forget to return state at the end

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


          # TODO: add your code here
          # Don't forget to return state at the end

        end # receive

    run(state)
  end # run
end
# module
