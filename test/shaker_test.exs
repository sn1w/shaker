defmodule ShakerTest do
  use ExUnit.Case
  doctest Shaker

  test "cli entrypoint test" do
    arg = ["-p", "200", "-v", "-s", "scenarios/*"]
    result = Shaker.parser(arg)
    options = elem(result, 0)
    assert options[:parallel] == 200
    assert options[:verbose] == true
    assert options[:scenarios] == "scenarios/*"
  end

  test "cli entrypoint test2" do
    arg = ["-p", "51"]
    result = Shaker.parser(arg)
    options = elem(result, 0)
    assert options[:parallel] == 51
    assert options[:verbose] == nil
  end

  test "cli entrypoint invalid format" do
    arg = ["-p", "something"]
    result = Shaker.parser(arg)
    options = elem(result, 0)
    assert options[:parallel] == nil
    assert options[:verbose] == nil
  end

  test "loading glob path tests" do
    files = Shaker.load_scenarios("scenarios/*.exs")
    assert length(files) == 2
    assert ["scenarios/http_sample.exs", "scenarios/websocket_sample.exs"] == files
  end

  test "loading scenario tests" do
    Shaker.launch_supervisor
    Shaker.load_scenarios("scenarios/*.exs") |> Shaker.invoke_scenarios
  end

  # test "websocket testing" do
  #   {{:module, loadModule, _, _}, _} = Code.eval_file("scenarios/websocket_sample.exs")
  #   result = loadModule.run()
  #   IO.inspect(result)
  #   assert result.case_result == "Hello"
  # end

  # test "https testing" do
  #   {{:module, loadModule, _, _}, _} = Code.eval_file("scenarios/http_sample.exs")
  #   result = loadModule.run()
  #   IO.inspect(result)
  #   assert result.case_result == "Hello"
  # end
end