defmodule GossipActor do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__,%{})
  end

  # init
  def init(state) do
    actual_neighbours = Helper.getNeighbours(state.neighbours,state.topology,state.name)
    # IO.inspect actual_neighbours
    new_state = Map.put(state,:neighbours,actual_neighbours)
    {:ok,new_state}
  end

  # handle cast for being messaged
  def handle_cast({:gossip,start_time},state) do
    msg_count = state.msg_count
    msg_count = msg_count+1
    # IO.puts "@ #{state.name} , msg_cnt=#{msg_count}"
    if msg_count == 1 do
      # IO.puts "#{state.name} ------------------reached"
      spawn_link(__MODULE__,:gossipContinue,[state.neighbours,state.name,start_time])
      # IO.puts "after spawn"
      count = :ets.update_counter(:time_table, "count", {2,1})
      if count == state.numNodes do
        endTime = System.monotonic_time(:millisecond) - start_time
        IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
    end

    # if msg_count == 1 do
    #   # IO.puts "starting process #{state.name}"
    #   spawn_link(__MODULE__,:gossipContinue,[state.neighbours,state.name,start_time])
    # end

    if msg_count == 10 do
      # IO.puts "killing process __________#{state.name}"
      exit(:normal)
    end
    new_state = Map.put(state,:msg_count,msg_count)
    {:noreply,new_state}
  end

  # handle cast for final state update
  def handle_cast({:update_neighbours,current_neighbours},state) do
    new_state = Map.put(state,:neighbours,current_neighbours)
    if Enum.empty?(state.neighbours) do
      Process.exit(self(),:normal)
    end
    {:noreply,new_state}
  end

  # gossip continue
  def gossipContinue(neighbours,name,start_time) do
    {next_one,current_neighbours} = Helper.randomNeighbour(neighbours,name)
    # IO.puts "#{name} ----> #{next_one}"
    GenServer.cast(next_one,{:gossip,start_time})
    gossipContinue(current_neighbours,name,start_time)
  end

end
