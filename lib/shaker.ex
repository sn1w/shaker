defmodule Shaker do
  @doc """
  launch supervisor used by tasks.
  """
  def launch_supervisor() do
    children = [
      {Task.Supervisor, name: Shaker.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  
  """
  def validate(%Shaker.CLI.Parser.Arguments.Master{} = arguments) do
    scenario_paths = arguments.scenarios |> Shaker.IO.extract 
    scenario_len = scenario_paths |> length
    case scenario_len do
      0 -> [error: "failed to load scenarios. please apply the collect path (-s, --scenarios)"]
      _ -> %{arguments | schenario_paths: scenario_paths}
    end
  end

  def validate(arguments) do
    arguments
  end


  def start(%Shaker.CLI.Parser.Arguments.Master{} = arguments) do
    arguments.node_name |> String.to_atom |> Node.start

    launch_supervisor()

    # try to connect specified Node
    arguments.hosts |> Enum.each(fn host ->
      case Node.connect(host) do
        :ignored ->
          IO.puts(:stderr, "Failed to connect node, #{host}")
          exit(:shutdown)
        false ->
          IO.puts(:stderr, "Failed to connect node, #{host}")
          exit(:shutdown)
        true ->
          IO.puts("Connection node #{host} successful")
      end
    end)

    Shaker.Scenario.Executor.execute(arguments.scenario_paths, arguments.hosts, arguments.parallel, arguments.loop)
  end

  def start(%Shaker.CLI.Parser.Arguments.Slave{} = arguments) do
    # launch slave mode
    launch_supervisor()
    arguments.node_name |> Node.start
    :timer.sleep(:infinity)
  end

  def start(arguments) do
    IO.puts(:stderr, arguments[:error])
  end

  @doc """
  entrypoint
  """
  def main(args) do
    args 
    |> Shaker.CLI.Parser.parse 
    |> validate 
    |> start
  end
end
