defmodule Proj2 do

  def start(numNodes,topology,algo) do
    Topology.topo_check
    numNodes = numCorrections(numNodes,topology)
    algorithm_select(numNodes,topology,algo)
    infiniteloop()
  end

  def numCorrections(numNodes,topology) do
    case topology do
      "full network" -> numNodes
      "line" -> numNodes
      "imperfect line" -> numNodes
      "random 2D grid" -> numNodes
      "torus" -> Helper.square_upperbound(numNodes)
      "3D" -> Helper.cube_upperbound(1,numNodes)
    end
  end

  def algorithm_select(numNodes,topology,algo) do
    case algo do
      "gossip" ->
        namesList = 
        if(topology == "random 2D grid") do
          create_nodes(numNodes)
        else
          Helper.nameActors(numNodes)
        end
        #namesList = Helper.nameActors(numNodes)
        create_actors_for_gossip(namesList,numNodes,topology)
        start_time = System.monotonic_time(:millisecond)
        time_table = :ets.new(:time_table, [:set, :public, :named_table])
        :ets.insert(time_table, {"count",0})
        startGossip(namesList,start_time)

      "pushsum" ->
        namesList = 
        if (topology == "random 2D grid") do
          create_nodes(numNodes)
          #create_actor_pushsum_2d(namesList,numNodes,topology)
        else
          Helper.nameActors(numNodes)
          #create_actors_for_pushsum(namesList,numNodes,topology)
        end
        #namesList = Helper.nameActors(numNodes)
        create_actors_for_pushsum(namesList,numNodes,topology)
        start_time = System.monotonic_time(:millisecond)
        time_table = :ets.new(:time_table, [:set, :public, :named_table])
        :ets.insert(time_table, {"count",0})
        startPushsum(namesList,start_time)
    end
  end

  def create_nodes(numNodes) do
    #IO.puts"#{numNodes} in create_nodes"
    namesList =[]
    namesList =
    (1..numNodes)
    |>Enum.map(fn(node) ->
      name = generaterand(namesList)
      #IO.puts "name = #{name}"
      name = name<>"actor_#{node}"
      String.to_atom(name)
    end)
    #IO.inspect namesList
    namesList
  end

  #Generating random x,y values
  def generaterand(namesList) do
    #IO.puts "in generater"
    x = Float.to_string(Float.ceil(:rand.uniform(),5))
    y = Float.to_string(Float.ceil(:rand.uniform(),5))

    x =
    if String.length(x) == 6 do
      x <> "0"
    else
      x
    end
    x =
    if String.length(x) == 5 do
      x <> "00"
    else
      x
    end
    x =
    if String.length(x) == 4 do
      x <> "000"
    else
      x
    end
    x =
    if String.length(x) == 3 do
      x <> "0000"
    else
      x
    end

    y =
    if String.length(y) == 3 do
      y <> "0000"
    else
      y
    end
    y =
    if String.length(y) == 4 do
      y <> "000"
    else
      y
    end
    y =
    if String.length(y) == 5 do
      y <> "00"
    else
      y
    end
    y =
    if String.length(y) == 6 do
      y <> "0"
    else
      y
    end 

    z = x <> y
    if (Enum.member?(namesList,z)) do
      z = generaterand(namesList)
    else
      z
    end
    z
  end


  def create_actors_for_gossip(namesList,numNodes,topology) do
    Enum.map(namesList,fn(name) ->
      {:ok,pid} =
      GenServer.start_link(GossipActor,%{msg_count: 0,neighbours: namesList -- [name], name: name,topology: topology,numNodes: numNodes})
      try do
        Process.register(pid,name)
      rescue
        _e in ArgumentError -> false
      end
    end)
  end

  def startGossip(namesList,start_time) do
    IO.puts "starting gossip"
    GenServer.cast(Enum.at(namesList,0),{:gossip,start_time})
    # Helper.span(namesList,start_time)
  end

  def create_actors_for_pushsum(namesList,numNodes,topology) do
    pids =
    Enum.map(namesList,fn(name) ->
      this = to_string(name)
      no = 
      if topology == "random 2D grid" do
        String.to_integer(String.slice(this,20..-1))
      else
        String.to_integer(String.slice(this,6..-1))
      end
      
      #String.to_integer(String.slice(this,6..-1))
      
      {:ok,pid} =
      GenServer.start_link(PushSumActor,%{nc_count: 0,neighbours: namesList -- [name], name: name,topology: topology,s: no,w: 1.0, numNodes: numNodes})
      try do
        Process.register(pid,name)
      rescue
        _e in ArgumentError -> false
      end
    end)
  end

  def startPushsum(namesList,start_time) do
    # IO.puts "starting pushsum"
    GenServer.cast(Enum.at(namesList,0),{:pushsum,0.0,0.0,start_time})
  end

  def infiniteloop() do
    infiniteloop()
  end

  # def ets_table(table_name) do
  #   time_table = :ets.new(:time_table, [:named_table,:public])
  #   :ets.insert(time_table, {"count",0})
  # end
end
