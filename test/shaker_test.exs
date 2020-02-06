defmodule ShakerTest do
  use ExUnit.Case
  doctest Shaker

  test "loading glob path tests" do
    files = Shaker.extract_scenario_locations("scenarios/*.exs")
    assert length(files) == 2
    assert ["scenarios/http_sample.exs", "scenarios/websocket_sample.exs"] == files
  end

  test "loading scenario tests" do
    contents = Shaker.extract_scenario_locations("test_scenarios/*.exs") |> Shaker.read_scenarios
    assert length(contents) == 1
  end

  test "compile scenario tests" do
    results = Shaker.extract_scenario_locations("test_scenarios/*.exs") 
              |> Shaker.read_scenarios
              |> Shaker.compile_scenarios
    assert length(results) == 1
  end

  test "deploy scenario tests" do
    Shaker.launch_supervisor()
    compiled = Shaker.extract_scenario_locations("scenarios/*.exs") 
              |> Shaker.read_scenarios
              |> Shaker.compile_scenarios
    results = compiled |> Enum.map(fn x -> x |> Shaker.deploy_modules([Node.self]) end)
    assert length(results) == 2
  end

  test "invoke scenario tests" do
    Shaker.launch_supervisor()
    locations = Shaker.extract_scenario_locations("test_scenarios/*.exs") 
    Shaker.invoke_scenarios(locations, [Node.self]) 
  end
end