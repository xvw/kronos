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

  @typedoc """
  This type represents a triplet of non negative values
  """
  @type non_neg_triplet :: {
    non_neg_integer, 
    non_neg_integer, 
    non_neg_integer
  }

  @typedoc """
  This type represents a couple date-time
  """
  @type datetime_t :: {
    non_neg_triplet, 
    non_neg_triplet
  }


  # Definition of the Metric-System

  use Mizur.System

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
  Converts a `Kronos.datetime_t` to a `Kronos.t`
  """
  @spec new!(datetime_t) :: t 
  def new!(erl_tuple) do 
    erl_tuple
    |> NaiveDateTime.from_erl!()
    |> from_naive!()
  end

  @doc """
  Converts a couple of `Kronos.non_neg_triplet` to a `Kronos.t`
  """
  @spec new!(non_neg_triplet, non_neg_triplet) :: t 
  def new!(date, time), do: new!({date, time})

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

  @doc """
  Converts a `NaiveDateTime.t` into a `Kronos.t`. The function 
  raise an Raise an `ArgumentError` if the naive datetime is not 
  valid.
  """
  @spec from_naive!(NaiveDateTime.t) :: t 
  def from_naive!(naive, timezone \\ "Etc/UTC") do 
    naive 
    |> DateTime.from_naive!(timezone)
    |> from_datetime()
  end
  

end
