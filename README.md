# Proj2

**TODO: Add description**

## Installation


Group Members: 
---------------
Akshay Rechintala (UFID: 4581-6988)
Keerthi Gudur (UFID: 8241-4961)

The overall goal of your program is to implement gossip and push up protocol using different topologies and comparing the results.

Instruction to run code:
------------------------
mix run lib/proj2_main.ex numNodes topology algorithm. This command is for Windows OS. 
Output displays the convergence time.

Topology names for running code:

full network: "full network"
line: "line"
imperfect line: "imperfect line"
3D: "3D"
torus: "torus"
random 2D: "random 2D grid"

Protocols:
"gossip"
"pushsum"

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `proj2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:proj2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/proj2](https://hexdocs.pm/proj2).

