defmodule Kronos do

  @moduledoc """
  Kronos is a tool to facilitate the manipulation of dates (via Timestamps).
  """


  @typedoc """
  This type represents a typed timestamp
  """
  @type t :: {
    {
      Kronos, 
      (:second | :minute | :hour | :day),
      true,
      (number -> float),
      (number -> float)
    }, float
  }

  use Mizur.System

  # Definition of the Metric-System

  type second
  type minute = 60 * second
  type hour   = 60 * 60 * second
  type day    = 24 * 60 * 60 * second

  @doc """
  Converts a number to a `Kronos.t`
  """
  @spec new(number()) :: t
  def new(timestamp), do: second(timestamp)

  @doc """
  Returns the current timestamp (in a `Kronos.t`)
  """
  @spec now() :: t 
  def now() do 
    DateTime.utc_now
    |> DateTime.to_unix(:second)
    |> second()
  end

  @doc """
  Returns the wrapped values (into a `Kronos.t`) as an 
  integer in `second`. This function is mainly used to convert 
  `Kronos.t` to` DateTime.t`.

      iex> x = Kronos.new(2000)
      ...> Kronos.to_integer(x)
      2000

  """
  @spec to_integer(t) :: integer
  def to_integer(timestamp) do 
    elt = Mizur.from(timestamp, to: second())
    round(Mizur.unwrap(elt))
  end

  @doc """
  Converts a `Kronos.t` to a `DateTime.t`, the result is wrapped 
  into `{:ok, value}` or `{:error, reason}`.

      iex> ts = 1493119897
      ...> a  = Kronos.new(ts)
      ...> b  = DateTime.from_unix(1493119897)
      ...> Kronos.to_datetime(a) == b 
      true
  """
  @spec to_datetime(t) :: {:ok, DateTime.t} | {:error, atom}
  def to_datetime(timestamp) do
    timestamp 
    |> to_integer()
    |> DateTime.from_unix(:second)
  end

  @doc """
  Converts a `Kronos.t` to a `DateTime.t`. Raise an `ArgumentError` if 
  the timestamp is not valid.

      iex> ts = 1493119897
      ...> a  = Kronos.new(ts)
      ...> b  = DateTime.from_unix!(1493119897)
      ...> Kronos.to_datetime!(a) == b 
      true
  """
  @spec to_datetime!(t) :: DateTime.t
  def to_datetime!(timestamp) do
    timestamp
    |>to_integer()
    |> DateTime.from_unix!(:second)
  end

  @doc """
  Converts a `DateTime.t` into a `Kronos.t`
  """
  @spec from_datetime(DateTime.t) :: t 
  def from_datetime(datetime) do
    datetime 
    |> DateTime.to_unix(:second)
    |> second()
  end

end
