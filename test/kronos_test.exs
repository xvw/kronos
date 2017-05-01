defmodule KronosTest do
  use ExUnit.Case
  doctest Kronos

  # Timestamp for : 2017/04/25 22:21:15
  @ts 1493158875
  @dt DateTime.from_unix!(@ts)


  def mock(:day, year, month, day) do 
    Kronos.new!({year, month, day}, {0, 0, 0})
  end

  def mock(:day, year, month, day, h, m, s) do 
    Kronos.new!({year, month, day}, {h, m, s})
  end

  def mock(:duration, year1, year2) do 
    a = Kronos.new!({year1, 1, 1}, {0, 0, 0})
    b = Kronos.new!({year2, 1, 1}, {0, 0, 0})
    Kronos.laps(from: a, to: b)
  end

  test "Kronos.t creation" do
    {:ok, t} = Kronos.new(@ts)
    assert Kronos.to_datetime!(t) == @dt
  end

  test "Kronos.t creation failure" do 
    r = Kronos.new({-2, 10, 10},{-3, 12, 68})
    assert {:error, :invalid_date} == r
  end

  test "Kronos.t arithmetics operations" do 
    day = @dt.day + 2
    min = @dt.minute + 12

    use Kronos.Infix, only: [+: 2]
    t = Kronos.new!(@ts) + Kronos.day(2) + Kronos.minute(12)

    m =
      @dt 
      |> Map.put(:day, day)
      |> Map.put(:minute, min)

    assert Kronos.to_datetime!(t) == m

  end

  test "for truncate" do 
    a = mock(:day, 2017, 5, 6, 20, 12, 10)
    b = mock(:day, 2017, 2, 13, 17, 25, 59)
    c = mock(:day, 2002, 9, 15, 1, 2, 3)
    d = mock(:day, 1970, 1, 1)


    assert Kronos.truncate(a, at: Kronos.minute) == mock(:day, 2017, 5, 6, 20, 12, 0)
    assert Kronos.truncate(a, at: Kronos.hour) == mock(:day, 2017, 5, 6, 20, 0, 0)
    assert Kronos.truncate(a, at: Kronos.day) == mock(:day, 2017, 5, 6)
    assert Kronos.truncate(a, at: Kronos.second) == a

    assert Kronos.truncate(b, at: Kronos.minute) == mock(:day, 2017, 2, 13, 17, 25, 0)
    assert Kronos.truncate(b, at: Kronos.second) == b
    assert Kronos.truncate(b, at: Kronos.hour) == mock(:day, 2017, 2, 13, 17, 0, 0)
    assert Kronos.truncate(b, at: Kronos.day) == mock(:day, 2017, 2, 13)

    assert Kronos.truncate(c, at: Kronos.minute) == mock(:day, 2002, 9, 15, 1, 2, 0)
    assert Kronos.truncate(c, at: Kronos.second) == c
    assert Kronos.truncate(c, at: Kronos.hour) == mock(:day, 2002, 9, 15, 1, 0, 0)
    assert Kronos.truncate(c, at: Kronos.day) == mock(:day, 2002, 9, 15)

    assert Kronos.truncate(d, at: Kronos.minute) == d
    assert Kronos.truncate(d, at: Kronos.second) == d
    assert Kronos.truncate(d, at: Kronos.hour) == d
    assert Kronos.truncate(d, at: Kronos.day) == d

  end


  test "for truncate negative ts" do 
    a = mock(:day, 1908, 5, 6, 20, 12, 10)
    b = mock(:day, 1907, 2, 13, 17, 25, 59)
    c = mock(:day, 1958, 9, 15, 1, 2, 3)
    d = mock(:day, 1965, 1, 1)


    assert Kronos.truncate(a, at: Kronos.minute) == mock(:day, 1908, 5, 6, 20, 12, 0)
    assert Kronos.truncate(a, at: Kronos.hour) == mock(:day, 1908, 5, 6, 20, 0, 0)
    assert Kronos.truncate(a, at: Kronos.day) == mock(:day, 1908, 5, 6)

    assert Kronos.truncate(b, at: Kronos.minute) == mock(:day, 1907, 2, 13, 17, 25, 0)
    assert Kronos.truncate(b, at: Kronos.hour) == mock(:day, 1907, 2, 13, 17, 0, 0)
    assert Kronos.truncate(b, at: Kronos.day) == mock(:day, 1907, 2, 13)

    assert Kronos.truncate(c, at: Kronos.minute) == mock(:day, 1958, 9, 15, 1, 2, 0)
    assert Kronos.truncate(c, at: Kronos.hour) == mock(:day, 1958, 9, 15, 1, 0, 0)
    assert Kronos.truncate(c, at: Kronos.day) == mock(:day, 1958, 9, 15)


    assert Kronos.truncate(a, at: Kronos.second) == a
    assert Kronos.truncate(b, at: Kronos.second) == b
    assert Kronos.truncate(c, at: Kronos.second) == c

    assert Kronos.truncate(d, at: Kronos.second) == d
    assert Kronos.truncate(d, at: Kronos.minute) == d
    assert Kronos.truncate(d, at: Kronos.hour) == d
    assert Kronos.truncate(d, at: Kronos.day) == d


  end

  test "truncate for week !" do 

  end
  

  test "For Day of week" do 

    a = mock(:day, 2017, 5, 6)  # :sat
    b = mock(:day, 2017, 2, 13) # :mon
    c = mock(:day, 2002, 9, 15) # :sun
    d = mock(:day, 1989, 11, 3) # :fri
    e = mock(:day, 2026, 12, 9) # :wed
    f = mock(:day, 2029, 6, 5)  # :tue
    g = mock(:day, 1970, 1, 1)  # :thu
    
    assert Kronos.day_of_week(a) == :sat
    assert Kronos.day_of_week(b) == :mon
    assert Kronos.day_of_week(c) == :sun
    assert Kronos.day_of_week(d) == :fri
    assert Kronos.day_of_week(e) == :wed
    assert Kronos.day_of_week(f) == :tue
    assert Kronos.day_of_week(g) == :thu
  end

  test "Days with negative timestamp" do 

    a = mock(:day, 1907, 5, 4)
    b = mock(:day, 1907, 6, 10)
    c = mock(:day, 1907, 2, 17)
    d = mock(:day, 1907, 3, 22)
    e = mock(:day, 1911, 5, 10)
    f = mock(:day, 1911, 6, 6)
    g = mock(:day, 1911, 4, 27)
    
    assert Kronos.day_of_week(a) == :sat
    assert Kronos.day_of_week(b) == :mon
    assert Kronos.day_of_week(c) == :sun
    assert Kronos.day_of_week(d) == :fri
    assert Kronos.day_of_week(e) == :wed
    assert Kronos.day_of_week(f) == :tue
    assert Kronos.day_of_week(g) == :thu
  end
  

  test "next & pred 1" do 
    a = mock(:day, 2016, 2, 4)
    af = Kronos.next(Kronos.week(start: :mon), of: a)
    bf = Kronos.pred(Kronos.week(start: :sun), of: a)
    assert af == mock(:day, 2016, 2, 8)
    assert bf == mock(:day, 2016, 1, 24)
  end

  test "next" do 
    a = mock(:day, 2016, 2, 4, 13, 28, 47)
    af = Kronos.next(Kronos.day(), of: a)
    assert af == mock(:day, 2016, 2, 5)
  end

  test "pred" do 
    a = mock(:day, 2016, 2, 4, 13, 28, 47)
    af = Kronos.pred(Kronos.day(), of: a)
    assert af == mock(:day, 2016, 2, 3)
  end
  
  

end
