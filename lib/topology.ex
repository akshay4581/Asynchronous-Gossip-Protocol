defmodule Topology do

  def topo_check do
    IO.puts "in topology"
  end

  def full_network(list) do
    # IO.puts "in topology full network"
    list
  end

  def line(list,name) do
    len = length(list)+1
    this = to_string(name)
    no = String.to_integer(String.slice(this,6..-1))
    if(no == 1) do
      [String.to_atom("actor_#{2}")]
    else
      if(no == len) do
        [String.to_atom("actor_#{Integer.to_string(len-1)}")]
      else
        [String.to_atom("actor_#{Integer.to_string(no-1)}"), String.to_atom("actor_#{Integer.to_string(no+1)}")]
      end
    end
  end

  def imperfect_line(list,name) do
    len = length(list)+1
    this = to_string(name)
    no = String.to_integer(String.slice(this,6..-1))
    if(no == 1) do
      [String.to_atom("actor_#{2}")]
    else
      if(no == len) do
        [String.to_atom("actor_#{Integer.to_string(len-1)}")]
      else
        first =
        [String.to_atom("actor_#{Integer.to_string(no-1)}"), String.to_atom("actor_#{Integer.to_string(no+1)}")]
        next =
        list -- first
        |>Enum.random()
        first ++ [next]
      end
    end
  end

  def torus(list,name) do
    list = list ++ [name]
    neighbours = []
    this = to_string(name)
    n = length(list)
    no = String.to_integer(String.slice(this,6..-1))
    cols = trunc(:math.ceil(:math.sqrt(n)))
    rows = div(n, cols)
    x =
    if rem(no,cols) == 0 do
      div(no,cols)-1
    else
      div(no,cols)
    end

    y =
    if rem(no, cols) == 0 do
      cols
    else
      rem(no, cols)
    end
    # ___regular grid neighbours___
    # r-1,c
    neighbours = neighbours ++ validate_neighbour(x-1,y,rows,cols,n,name)
    # r+1,c
    neighbours = neighbours ++ validate_neighbour(x+1,y,rows,cols,n,name)
    # r,c-1
    neighbours = neighbours ++ validate_neighbour(x,y-1,rows,cols,n,name)
    # r,c+1
    neighbours = neighbours ++ validate_neighbour(x,y+1,rows,cols,n,name)

    # ____extras for torus___
    # top row
    neighbours =
    if x == 0 do
      neighbours ++ [String.to_atom("actor_#{((rows-1)*cols)+y}")]
    else
      neighbours
    end
    # bottom row
    neighbours =
    if x == rows-1 do
      neighbours ++ [String.to_atom("actor_#{y}")]
    else
      neighbours
    end
    # first column
    neighbours =
    if y == 1 do
      neighbours ++ [String.to_atom("actor_#{(x*cols)+cols}")]
    else
      neighbours
    end
    # last column
    neighbours =
    if y == cols do
      neighbours ++ [String.to_atom("actor_#{((x*cols)+1)}")]
    else
      neighbours
    end
    neighbours
  end

  def validate_neighbour(x,y,rows,cols,n,name) do
      if x>=0 && x<=rows-1 && y>0 && y<=cols do
        next = ((x*cols)+y)
        if(next <= n) do
          [String.to_atom("actor_#{next}")]
        else
          []
        end
      else
        []
      end
  end


  # 3D topology

  def threeD(list,name) do
    # IO.puts " in topology.3D"
    list = list ++ [name]
    neighbours = []
    this = to_string(name)
    n = length(list)
    no = String.to_integer(String.slice(this,6..-1))
    se = no

    cols = calculate_cuberoot(1,n)
    rows = div(n, cols*cols)
    k = div(n, cols*cols)
    #IO.puts "#{rows} col = #{cols} no = #{no}"
    # IO.puts "#{no}"

    z =
    if rem(no,cols*rows) == 0 do
      div(no,cols*rows)-1
    else
      div(no,cols*rows)
    end

    y =
    if rem(no, cols) == 0 do
      cols
    else
      rem(no, cols)
    end

    #no =
    #if no>cols*rows do
    #  if rem(no,k) == 0 do
    #  div(no,k)-1
    #  else
    #    div(no,k)
    #  end
    #else
    #  no
    #end

    #IO.puts "#{no}"
    x =
    if rem(no,cols) == 0 do
      div(no,cols)-1
    else
      div(no,cols)
    end

    x =
    if z>0 do
      rem(x,(z*k))
    else
      x
    end

   #IO.puts "x=#{x} y= #{y} z= #{z} no = #{no}"


    # __regular grid neighbours__
    # r-1,c
    neighbours = neighbours ++ validate_neighbour3d(x-1,y,z,rows,cols,k,n,name,se)
    # r+1,c
    neighbours = neighbours ++ validate_neighbour3d(x+1,y,z,rows,cols,k,n,name,se)
    # r,c-1
    neighbours = neighbours ++ validate_neighbour3d(x,y-1,z,rows,cols,k,n,name,se)
    # r,c+1
    neighbours = neighbours ++ validate_neighbour3d(x,y+1,z,rows,cols,k,n,name,se)
    # for connections between each 2D layer
    neighbours = neighbours ++ validate_neighbour3d_o(x,y,z,rows,cols,k,n,name,se)
    neighbours = neighbours ++ validate_neighbour3d_i(x,y,z,rows,cols,k,n,name,se)
  end

  def validate_neighbour3d_o(x,y,z,rows,cols,k,n,name,se) do
      if z != 0 do
       next = -(k*k)+(se)
       #IO.puts "#{next}"
       if(next <= n && next != se) do
          # IO.puts "#{name}'s neighbour = actor_#{next}'"
          [String.to_atom("actor_#{next}")]
        else
          []
       end
      else
        []
      end
  end

  def validate_neighbour3d_i(x,y,z,rows,cols,k,n,name,se) do
    if z != k-1 do
     next = (se)+(k*k)
     #IO.puts "#{next}"
     if(next <= n && next != se) do
        # IO.puts "#{name}'s neighbour = actor_#{next}'"
        [String.to_atom("actor_#{next}")]
      else
        []
     end
    else
      []
    end
  end

  def validate_neighbour3d(x,y,z,rows,cols,k,n,name,se) do
    #IO.puts "x_new=#{x} y_new= #{y} z_new= #{z}"

    if x>=0 && x<=rows-1 && y>0 && y<=cols do
      next = ((x*cols)+y)+(z*k*k)
      #IO.puts "#{next}"
      if(next <= n && next != se) do
        # IO.puts "#{name}'s neighbour = actor_#{next}'"
        [String.to_atom("actor_#{next}")]
      else
        []
      end
    else
      []
    end
  end

  def calculate_cuberoot(x,n) do
    test = (x*x*x)==n
    if test do
      x
    else
      calculate_cuberoot(x+1,n)
    end
  end


  def random_2D(list,name) do
    neighbour = []
    this = to_string(name)

    n = length(list)
    #IO.puts "in random_2D"

    neighbour =
    list|>
    Enum.map(fn(val) ->
      #IO.puts "#{this}"
      if check_neigh(val,this) do
        #IO.puts "inside check_neigh"
        [val]
      else
        []
      end
    end)
    List.flatten(neighbour)
    # IO.puts("hdahda #{neighbour}")
   # IO.inspect neighbour

    # neighbours =
    # (1..n)
    # |>Enum.map(fn(node) ->
    #   nei = check_neigh(list,this)
    #   IO.puts "name = #{name}"
    #   String.to_atom(nei)
    # end)
    # IO.inspect neighbours
    # neighbours
  end

  def check_neigh(val,this)do
    #IO.puts "current == #{this} new == #{val}"
    x = elem(Float.parse(String.slice(this,0..6)),0)
    y = elem(Float.parse(String.slice(this,7..13)),0)

    valx = elem(Float.parse(String.slice(this,0..6)),0)
    valy = elem(Float.parse(String.slice(this,7..13)),0)

    res = (:math.sqrt(:math.pow((x-valx),2)+:math.pow((y-valy),2))) <= 0.1
    #IO.puts "#{res}"
    res
  end

end
