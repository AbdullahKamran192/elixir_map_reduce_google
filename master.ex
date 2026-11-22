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

    IO.inspect(files, label: "INSPECTING FILES WITHIN Master.init()")

    state = %{
      parent: parent,
      files: files
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

          #IO.inspect(state.files, label: "INSPECTING FILES WITHIN Master.run()")

          send(pid, {:map, 1, Enum.at(state.files, 0), 1})


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
          # TODO: add your code here
          # Don't forget to return state at the end

        end # receive

    run(state)
  end # run
end
# module
