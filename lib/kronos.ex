defmodule Kronos do

  @moduledoc """
  Kronos is a tool to facilitate the manipulation of dates (via Timestamps).
  This library use the seconds as a reference. 
  

      iex> import Kronos
      ...> use Kronos.Infix
      ...> {:ok, t} = new({2010, 12, 20}, {0, 0, 0})
      ...> r = t + day(2) + hour(3) + minute(10) + second(13)
      ...> Kronos.to_string(r)
      "2010-12-22 03:10:13Z"


  """

  @first_day_of_week 3
  @days_of_week [
    :mon, 
    :tue, 
    :wed, 
    :thu, 
    :fri, 
    :sat, 
    :sun
  ]


  @typedoc """
  This type represents a typed timestamp
  """
  @type t :: Mizur.typed_value

  @typedoc """
  This type represents a specific week type
  """
  @type week_t :: {t, day_of_week}

  @typedoc """
  This type represents a metric_type
  """
  @type metric :: Mizur.metric_type | week_t
  
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

  @typedoc """
  This type represents the day of the week 
  """
  @type day_of_week :: 
    :mon | :tue | :wed | :thu | :fri | :sat | :sun

  # Internals helpers

  def one({mod, unit, _, _, _}), do: apply(mod, unit, [1])
  def one({t, _}), do: one(t)

  defp int_to_dow(i), do: Enum.at(@days_of_week, i)
  defp dow_to_int(d) do 
    Enum.find_index(
      @days_of_week, 
      fn(x) -> x == d end
    )
  end

  defp modulo(a, b) do 
    cond do 
      a >= 0 -> rem(a, b)
      true -> b - 1 - rem(-a-1, b)
    end 
  end

  defp second?({_, :second, _, _, _}), do: true 
  defp second?(_), do: false

  defp simple_week?({_, :week, _, _, _}), do: true 
  defp simple_week?(_), do: false

  # Definition of the Metric-System

  @doc """
  Monkeypatch to truncate `Kronos.t`.
  """
  @spec week([start: day_of_week]) :: week_t
  def week(start: day), do: {week(), day}

  use Mizur.System

  type second
  type minute = 60 * second
  type hour   = 60 * 60 * second
  type day    = 24 * 60 * 60 * second
  type week   = 7 * 24 * 60 * 60 * second


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
  Returns if the given year is a leap year.

      iex> Kronos.leap_year?(2004)
      true 

      iex> Kronos.leap_year?(2017)
      false

  """
  @spec leap_year?(non_neg_integer) :: boolean 
  def leap_year?(year) do 
    rem(year, 4) === 0 
      and (rem(year, 100) > 0 or rem(year, 400) === 0)
  end

  @doc """
  Returns a `Kronos.t` with the number of days in a month, 
  the month is referenced by `year` and `month (non neg integer)`.

      iex> Kronos.days_in(2004, 2)
      Kronos.day(29)

      iex> Kronos.days_in(2005, 2)
      Kronos.day(28)

      iex> Kronos.days_in(2005, 1)
      Kronos.day(31)

      iex> Kronos.days_in(2001, 4)
      Kronos.day(30)

  """
  @spec days_in(non_neg_integer, 1..12) :: t
  def days_in(year, month), do: day(aux_days_in(year, month))
  defp aux_days_in(year, 2), do: (if (leap_year?(year)), do: 29, else: 28)
  defp aux_days_in(_, month) when month in [4, 6, 9, 11], do: 30
  defp aux_days_in(_, _), do: 31

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
  def new({_, _, _} = date, {_, _, _} = time) do
    new({date, time})
  end

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
  @spec after?(t, t, metric) :: boolean
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
  @spec before?(t, t, metric) :: boolean
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
  @spec equivalent?(t, t, metric) :: boolean
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
  @spec truncate(t, [at: metric]) :: t

  def truncate(timestamp, at: {_, dow}) do
    ts = truncate(timestamp, at: day()) 
    f = modulo(day_of_week_internal(ts) - dow_to_int(dow), 7)
    Mizur.sub(ts, day(f))
  end

  def truncate({base, _} = timestamp, at: t) do 
    cond do 
      second?(t) -> timestamp
      simple_week?(t) -> truncate(timestamp, at: week(start: :mon))
      true ->
        seconds = to_integer(timestamp)
        factor  = to_integer(one(t))
        (seconds - modulo(seconds, factor))
        |> second() 
        |> Mizur.from(to: base)
      end 
  end


  @doc """
  Returns the difference (always positive) between to members 
  of a duration.

      iex> duration = KronosTest.mock(:duration, 2017, 2018)
      ...> Mizur.from((Kronos.diff(duration)), to: Kronos.day)
      Kronos.day(365)
  """
  @spec diff(duration) :: t
  def diff(duration) do 
    {a, b} = Mizur.Range.sort(duration)
    Mizur.sub(b, a)
  end

  @doc """
  Jump to the next value of a `type`. For example 
  `next(Kronos.day, of: Kronos.new({2017, 10, 10}, {22, 12, 12}))` give the 
  date : `2017-10-11, 0:0:0`.

      iex> t = KronosTest.mock(:day, 2017, 10, 10)
      ...> Kronos.next(Kronos.day, of: t)
      KronosTest.mock(:day, 2017, 10, 11)
  """
  @spec next(metric, [of: t]) :: t
  def next(t, of: ts) do
    Mizur.add(ts, one(t))
    |> truncate(at: t)
  end


   @doc """
  Jump to the pred value of a `type`. For example 
  `next(Kronos.day, of: Kronos.new({2017, 10, 10}, {22, 12, 12}))` give the 
  date : `2017-10-09, 0:0:0`.

      iex> t = KronosTest.mock(:day, 2017, 10, 10)
      ...> Kronos.pred(Kronos.day, of: t)
      KronosTest.mock(:day, 2017, 10, 9)
  """
  @spec pred(metric, [of: t]) :: t
  def pred(t, of: ts) do 
    Mizur.sub(ts, one(t))
    |> truncate(at: t)
  end


  @doc """ 
  Returns the day of the week from a `Kronos.t`. 
  0 for Monday, 6 for Sunday.

      iex> a = KronosTest.mock(:day, 1970, 1, 1, 12, 10, 11)
      ...> Kronos.day_of_week_internal(a)
      3

      iex> a = KronosTest.mock(:day, 2017, 4, 29, 0, 3, 11)
      ...> Kronos.day_of_week_internal(a)
      5


  """
  @spec day_of_week_internal(t) :: 0..6
  def day_of_week_internal(ts) do 
    ts
    |> truncate(at: day())
    |> Mizur.from(to: day())
    |> Mizur.unwrap()
    |> round()
    |> Kernel.+(@first_day_of_week)
    |> modulo(7)
  end

  @doc """ 
  Returns the day of the week from a `Kronos.t`. 
  0 for Monday, 6 for Sunday.

      iex> a = KronosTest.mock(:day, 1970, 1, 1, 12, 10, 11)
      ...> Kronos.day_of_week(a)
      :thu

      iex> a = KronosTest.mock(:day, 2017, 4, 29, 0, 3, 11)
      ...> Kronos.day_of_week(a)
      :sat


  """
  @spec day_of_week(t) :: day_of_week
  def day_of_week(ts) do
    day_of_week_internal(ts)
    |> int_to_dow()
  end
  


end
