defmodule PushSumActor do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__,%{})
  end

  # init
  def init(state) do
    # IO.puts "In push Sum genserver"
    actual_neighbours = Helper.getNeighbours(state.neighbours,state.topology,state.name)
    new_state = Map.put(state,:neighbours,actual_neighbours)
    {:ok,new_state}
  end

  # handle cast for being messaged
  def handle_cast({:pushsum, s_message, w_message,start_time}, state) do
    s = state.s + s_message
    w = state.w + w_message
    change = abs(s/w - state.s/state.w)
    nc_count =
    if(change  < :math.pow(10,-10)) do
      state.nc_count+1
    else
      0
    end
    if(nc_count == 3) do
        count = :ets.update_counter(:time_table, "count", {2,1})
        if(count == state.numNodes) do
          endTime = System.monotonic_time(:millisecond) - start_time
          IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
          System.halt(1)
        else
          pushsumContinue(state.neighbours, state.name,start_time, {s/2 , w/2})
        end
    else
      pushsumContinue(state.neighbours, state.name,start_time, {s/2 , w/2})
    end

    new_state = Map.put(state,:nc_count,nc_count)
    new_state = Map.put(new_state,:s,s/2)
    new_state = Map.put(new_state,:w,w/2)
    {:noreply, new_state}
  end

  # handle cast for final state update
  def handle_cast({:update_neighbours,current_neighbours},state) do
    new_state = Map.put(state,:neighbours,current_neighbours)
    if Enum.empty?(state.neighbours) do
      Process.exit(self(),:normal)
    end
    {:noreply,new_state}
  end

  def pushsumContinue(neighbours, name,start_time, {s, w}) do
    {next_one,current_neighbours} = Helper.randomNeighbour(neighbours,name)
    GenServer.cast(next_one,{:pushsum,s,w,start_time})

  end

end
