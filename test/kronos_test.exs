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


  test "For Day of week" do 

    a = mock(:day, 2017, 5, 6)  # 5
    b = mock(:day, 2017, 2, 13) # 0 
    c = mock(:day, 2002, 9, 15) # 6
    d = mock(:day, 1989, 11, 3) # 4 
    e = mock(:day, 2026, 12, 9) # 2
    f = mock(:day, 2029, 6, 5)  # 1
    g = mock(:day, 1970, 1, 1)  # 3
    
    assert Kronos.day_of_week(a) == 5
    assert Kronos.day_of_week(b) == 0
    assert Kronos.day_of_week(c) == 6
    assert Kronos.day_of_week(d) == 4
    assert Kronos.day_of_week(e) == 2
    assert Kronos.day_of_week(f) == 1
    assert Kronos.day_of_week(g) == 3
  end
  

end
