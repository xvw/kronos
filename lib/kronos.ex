defmodule Kronos do

  @moduledoc """
  Kronos is a tool to facilitate the manipulation of dates (via Timestamps).
  This library use the seconds as a reference. 
  
  **The API does not use microsecond.**
  """


  @typedoc """
  This type represents a typed timestamp
  """
  @type t :: Mizur.typed_value
  
  @typedoc """
  This type represents a range between two timestamp
  """
  @type duration :: Mizur.Range.range

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
        {:ok, from_datetime(result)}
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
  Creates a duration between two `Kronos.t`. This duration 
  is a `Mizur.Range.range`.

      iex> a = Kronos.new!(1)
      ...> b = Kronos.new!(100)
      ...> Kronos.laps(a, b)
      Mizur.Range.new(Kronos.new!(1), Kronos.new!(100))
  """
  @spec laps(t, t) :: duration
  def laps(a, b), do: Mizur.Range.new(a, b)

  @doc """
  Check if a `Kronos.t` is include into a `Kronos.duration`.

      iex> duration = KronosTest.mock(:duration, 2017, 2018)
      ...> a = KronosTest.mock(:day, 2015, 12, 10)
      ...> b = KronosTest.mock(:day, 2017, 5, 10)
      ...> {Kronos.include?(a, in: duration), Kronos.include?(b, in: duration)}
      {false, true}
  """
  @spec include?(t, [in: duration]) :: boolean
  def include?(a, in: b), do: Mizur.Range.include?(a, in: b)

  @doc """
  Checks that two durations have an intersection.

      iex> durationA = KronosTest.mock(:duration, 2016, 2018)
      ...> durationB = KronosTest.mock(:duration, 2017, 2019)
      ...> Kronos.overlap?(durationA, with: durationB)
      true
  """
  @spec overlap?(duration, [with: duration]) :: boolean 
  def overlap?(a, with: b), do: Mizur.Range.overlap?(a, b)

  @doc """
  Creates a duration between two `Kronos.t`. This duration 
  is a `Mizur.Range.range`.

      iex> a = Kronos.new!(1)
      ...> b = Kronos.new!(100)
      ...> [from: a, to: b] |> Kronos.laps
      Mizur.Range.new(Kronos.new!(1), Kronos.new!(100))
  """
  @spec laps([from: t, to: t]) :: duration
  def laps(from: a, to: b), do: laps(a, b)
  

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
  `Kronos.after?(a, b)` check if `a` is later in time than `b`.

      iex> {a, b} = {Kronos.new!(2), Kronos.new!(1)}
      ...> Kronos.after?(a, b)
      true

  You can specify a `precision`, to ignore minutes, hours or days. 
  (By passing a `precision`, both parameters will be truncated via 
  `Kronos.truncate/2`).
  """
  @spec after?(t, t, Mizur.metric_type) :: boolean
  def after?(a, b, precision \\ second()) do 
    use Mizur.Infix, only: [>: 2]
    truncate(a, at: precision) > truncate(b, at: precision)
  end

  @doc """
  `Kronos.before?(a, b)` check if `a` is earlier in time than `b`.

      iex> {a, b} = {Kronos.new!(2), Kronos.new!(1)}
      ...> Kronos.before?(b, a)
      true

  You can specify a `precision`, to ignore minutes, hours or days. 
  (By passing a `precision`, both parameters will be truncated via 
  `Kronos.truncate/2`).
  """
  @spec before?(t, t, Mizur.metric_type) :: boolean
  def before?(a, b, precision \\ second()) do 
    use Mizur.Infix, only: [<: 2]
    truncate(a, at: precision) < truncate(b, at: precision)
  end


  @doc """
  `Kronos.equivalent?(a, b)` check if `a` is at the same moment of `b`.

      iex> {a, b} = {Kronos.new!(2), Kronos.new!(1)}
      ...> Kronos.equivalent?(b, a, Kronos.hour())
      true

  You can specify a `precision`, to ignore minutes, hours or days. 
  (By passing a `precision`, both parameters will be truncated via 
  `Kronos.truncate/2`).
  """
  @spec equivalent?(t, t, Mizur.metric_type) :: boolean
  def equivalent?(a, b, precision \\ second()) do 
    use Mizur.Infix, only: [==: 2]
    truncate(a, at: precision) == truncate(b, at: precision)
  end


  @doc """
  Rounds the given timestamp (`timestamp`) to the given type (`at`). 

      iex> ts = Kronos.new!({2017, 10, 24}, {23, 12, 07})
      ...> Kronos.truncate(ts, at: Kronos.hour())
      Kronos.new!({2017, 10, 24}, {23, 0, 0})
  
  For example : 
  -  truncate of 2017/10/24 23:12:07 at `minute` gives : 2017/10/24 23:12:00
  -  truncate of 2017/10/24 23:12:07 at `hour` gives : 2017/10/24 23:00:00
  -  truncate of 2017/10/24 23:12:07 at `day` gives : 2017/10/24 00:00:00

  """
  @spec truncate(t, [at: Mizur.metric_type]) :: t
  def truncate({base, _} = timestamp, at: {__MODULE__, unit, _, _, _} = _type) do 
    seconds = to_integer(timestamp)
    factor  = to_integer(apply(__MODULE__, unit, [1]))
    f = if (seconds >= 0), do: 0, else: factor
    (seconds - rem(seconds, factor) - f)
    |> second() 
    |> Mizur.from(to: base)
  end


  @doc """
  Returns the difference (always positive) between to members 
  of a duration.

      iex> duration = KronosTest.mock(:duration, 2017, 2018)
      ...> Mizur.from((Kronos.diff(duration)), to: Kronos.day)
      Kronos.day(365)
  """
  @spec diff(duration) :: Mizur.typed_value 
  def diff(duration) do 
    {a, b} = Mizur.Range.sort(duration)
    Mizur.sub(b, a)
  end


end
