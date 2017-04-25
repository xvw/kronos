defmodule KronosTest do
  use ExUnit.Case
  doctest Kronos

  # Timestamp for : 2017/04/25 22:21:15
  @ts 1493158875
  @dt DateTime.from_unix!(@ts)

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

    use Mizur.Infix, only: [+: 2]
    t = Kronos.new!(@ts) + Kronos.day(2) + Kronos.minute(12)

    m =
      @dt 
      |> Map.put(:day, day)
      |> Map.put(:minute, min)

    assert Kronos.to_datetime!(t) == m

  end


  test "Truncate" do 
    t = Kronos.new!(-@ts)
    r = Kronos.truncate(t, at: Kronos.minute)
    IO.inspect [Kronos.to_string(t), Kronos.to_string(r)]
  end
  

end
