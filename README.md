# Kronos

Kronos is a library to facilitate simple arithmetic operations between timestamps.
At [Dernier Cri](https://derniercri.io) (my ex-company),
we often have to handle DateTime. Kronos was designed to avoid having
to constantly convert DateTime into timestamps and vice-verça.

If you are looking for a complete library of time and date management,
Kronos is (maybe) not the ideal solution, and
I recommend [Timex](https://github.com/bitwalker/timex)!

Kronos relies on [Mizur](https://github.com/xvw/mizur) to decorate numerical
values of typing information.

The library supports Mizur arithmetic operations, Timestamps collisions,
inclusions between timestamps intervals (via Mizur.Range), and truncation of
timestamps. I invite you to read the full documentation for more information!

[https://hexdocs.pm/kronos](https://hexdocs.pm/kronos)

## Small examples

```elixir
import Kronos
use Kronos.Infix # Same of Mizur.Infix

{:ok, t} = new({2010, 12, 20}, {0, 0, 0})
# You can use timestamp or DateTime.t as parameter for Kronos.new

r = t + ~t(2)day + ~t(3)hour + ~t(10)minute + ~t(13)second
IO.puts Kronos.to_string(r) # will print "2010-12-22 03:10:13Z"
```



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kronos` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kronos, "~> 1.0.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kronos](https://hexdocs.pm/kronos).
