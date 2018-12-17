defmodule Helper do

  def square_upperbound(numNodes) do
    numNodes = :math.ceil(:math.sqrt(numNodes))
    trunc(numNodes*numNodes)
  end

  def cube_upperbound(x,numNodes) do
    test = (x*x*x)<numNodes
    if test do
      cube_upperbound(x+1,numNodes)
    else
      x*x*x
    end
  end

  def nameActors(numNodes) do
    namesList =
    (1..numNodes)
    |>Enum.map(fn(node) ->
      name = "actor_#{node}"
      String.to_atom(name)
    end)
    namesList
  end

  def aliveORnot(next) do
    try do
      pid = Process.whereis(next)
      pid !=nil && Process.alive?(pid)
    rescue
      _e in ArgumentError -> false
    end
  end

  def randomNeighbour(neighbours,name) do
    if Enum.empty?(neighbours) do
      Process.exit(self(),:normal)
    end
    next = Enum.random(neighbours)
    if aliveORnot(next) do
      {next,neighbours}
    else
      neighbours = neighbours -- [next]
      GenServer.cast(name,{:update_neighbours,neighbours})
      randomNeighbour(neighbours,name)
    end
  end

  def getNeighbours(list,topology,name) do
    # IO.puts "In getNeighbour"
    case topology do
      "full network" -> Topology.full_network(list)
      "line" -> Topology.line(list,name)
      "imperfect line" -> Topology.imperfect_line(list,name)
      "random 2D grid" -> Topology.random_2D(list,name)
      "torus" -> Topology.torus(list,name)
      "3D" -> Topology.threeD(list,name)
    end
  end

  def span(list, initTime) do
    aliveCount = numberOfNodesAlive(list, length(list), 0)
    if aliveCount < round(length(list)*0.1)  || aliveCount <= 2 do
        endTime = System.monotonic_time(:millisecond)
        IO.inspect ("Total time: #{endTime - initTime} milliseconds")
        Process.exit(self(), :normal)
    else
        span(list, initTime)
    end
end

def numberOfNodesAlive(_list, 0, count) do
    count
end

def numberOfNodesAlive(list, index, count) do
    if Helper.aliveORnot(Enum.at(list, index-1)) do
        numberOfNodesAlive(list, index-1, count+1)
    else
        numberOfNodesAlive(list, index-1, count)
    end
end

end
