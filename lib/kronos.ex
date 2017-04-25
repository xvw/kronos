defmodule Kronos do

  @moduledoc """
  Kronos is a tool to facilitate the manipulation of dates (via Timestamps).
  This library use the seconds as a reference. The API does not use 
  microsecond.
  """


  @typedoc """
  This type represents a typed timestamp
  """
  @type t :: Mizur.typed_value

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

  @typedoc """
  This type represents a failable result
  """
  @type result :: {:ok, t} | {:error, atom}


  # Definition of the Metric-System

  use Mizur.System

  type second
  type minute = 60 * second
  type hour   = 60 * 60 * second
  type day    = 24 * 60 * 60 * second


  @doc """
  Convert a `Kronos.t` into a string, use the 
  `DateTime` inspect.
  """
  @spec to_string(t) :: String.t
  def to_string(value) do 
    case to_datetime(value) do 
      {:error, reason} -> "Invalid[#{reason}]"
      {:ok, datetime}  -> "#{datetime}"
    end
  end

  @doc """
  Converts an integer (timestamp) to a `Kronos.result`
  """
  @spec new(integer) :: result
  def new(timestamp) when is_integer(timestamp) do 
    case DateTime.from_unix(timestamp) do 
      {:ok, _datetime} -> {:ok, second(timestamp)}
      {:error, reason } -> {:error, reason}
    end
  end

  @doc """
  Converts an erlang datetime representation to a `Kronos.result`
  """
  @spec new(datetime_t) :: result 
  def new({{_, _, _}, {_, _, _}} = erl_tuple) do 
    case NaiveDateTime.from_erl(erl_tuple) do
      {:error, reason1} -> {:error, reason1} 
      {:ok, naive} -> 
        {:ok, result} = DateTime.from_naive(naive, "Etc/UTC")
        from_datetime(result)
    end
  end

  @doc """
  Converts two tuple (date, time) to a `Kronos.result`
  """
  @spec new(non_neg_triplet, non_neg_triplet) :: result 
  def new({_, _, _} = date, {_, _, _} = time), do: new({date, time})

  @doc """
  Same of `Kronos.new/1` but raise an `ArgumentError` if the 
  timestamp creation failed.
  """
  @spec new!(integer | datetime_t) :: t
  def new!(input) do 
    case new(input) do 
      {:ok, result} -> result
      {:error, reason} ->
        raise ArgumentError, message: "Invalid argument, #{reason}"
    end
  end

  @doc """
  Same of `Kronos.new/2` but raise an `ArgumentError` if the 
  timestamp creation failed.
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

      iex> x = Kronos.new!(2000)
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
      ...> a  = Kronos.new!(ts)
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
      ...> a  = Kronos.new!(ts)
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
  """
  def truncate({base, _} = date, at: {__MODULE__, unit, _, _, _}) do 
    seconds = to_integer(date)
    factor  = to_integer(apply(__MODULE__, unit, [1]))
    f = if (seconds >= 0), do: 0, else: factor
    (seconds - rem(seconds, factor) - f)
    |> second() 
    |> Mizur.from(to: base)
  end


end
