defmodule Shaker.Arguments.Test do
  use ExUnit.Case

  test "cli entrypoint test" do
    arg = ["-p", "200", "-v", "-s", "scenarios/*", "-t", "30000", "-l", "20", "-h", "host1 host2"]
    result = Shaker.CLI.Parser.parse(arg)
    assert result.__struct__ == Shaker.CLI.Parser.Arguments.Master
    assert result.parallel == 200
    assert result.verbose == true
    assert result.scenarios == "scenarios/*"
    assert result.timeout == 30000
    assert result.loop == 20
    assert result.hosts == [:host1, :host2]
  end

  test "cli entrypoint test2" do
    arg = ["-p", "51"]
    result = Shaker.CLI.Parser.parse(arg)
    assert result.__struct__ == Shaker.CLI.Parser.Arguments.Master
    assert result.parallel == 51
    assert result.verbose == false
    assert result.scenarios == ""
  end

  test "cli entrypoint invalid format" do
    arg = ["-p", "something"]
    result = Shaker.CLI.Parser.parse(arg)
    assert result.__struct__ == Shaker.CLI.Parser.Arguments.Master
    assert result.parallel == 1
    assert result.verbose == false
    assert result.scenarios == ""
  end

  test "slave mode test" do
    arg = ["--slave", "--node", "slave@127.0.0.1"]
    result = Shaker.CLI.Parser.parse(arg)
    assert result.__struct__ == Shaker.CLI.Parser.Arguments.Slave
    assert result.node_name == :"slave@127.0.0.1"
  end
end