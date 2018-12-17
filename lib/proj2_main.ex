[numNodes,topology,algorithm]=System.argv()
numNodes = elem(Integer.parse(numNodes),0)
Proj2.start(numNodes,topology,algorithm)
# {time,_} = :timer.tc(Proj2, :start,[numNodes,topology,algorithm])
