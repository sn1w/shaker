defmodule ShakerTest do
  use ExUnit.Case
  doctest Shaker

  test "loading glob path tests" do
    files = Shaker.IO.extract("scenarios/*.exs")
    assert length(files) == 2
    assert ["scenarios/http_sample.exs", "scenarios/websocket_sample.exs"] == files
  end

  test "loading scenario tests" do
    contents = Shaker.IO.extract("test_scenarios/*.exs") |> Shaker.IO.read_contents
    assert length(contents) == 2
  end

  test "compile scenario tests" do
    results = Shaker.IO.extract("test_scenarios/*.exs") 
              |> Shaker.IO.read_contents
              |> Shaker.Module.compile
    assert length(results) == 2
  end

  test "deploy scenario tests" do
    Shaker.launch_supervisor()
    compiled = Shaker.IO.extract("test_scenarios/*.exs") 
              |> Shaker.IO.read_contents
              |> Shaker.Module.compile
    results = compiled |> Enum.map(fn x -> x |> Shaker.Module.deploy([Node.self]) end)
    assert length(results) == 2
  end

  test "invoke scenario tests" do
    Shaker.launch_supervisor()
    locations = Shaker.IO.extract("test_scenarios/*.exs")
    compiled = locations |> Shaker.IO.read_contents |> Shaker.Module.compile
    Shaker.Scenario.Executor.execute(compiled, [Node.self], 10, 2, "report.csv") 
  end

  test "integration test" do
    Shaker.main(["-s", "test_scenarios/*.exs", "-p", "30", "-l", "10"])
  end
end