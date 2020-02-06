defmodule Shaker do
  @doc """
  launch supervisor using by tasks
  """
  def launch_supervisor() do
    children = [
      {Task.Supervisor, name: Shaker.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def extract_scenario_locations(glob_path) do
    Path.wildcard(glob_path)
  end

  def read_scenarios(locations) do
    locations 
    |> Enum.map(
      fn (scenario_location) ->
        {:ok, content} = File.read(scenario_location)
        content
      end
    )
  end

  def compile_scenarios(contents) do
    contents
    |> Enum.map(
      fn (scenario) -> 
        {{:module, loadModule, _, _}, _} = Code.eval_string(scenario)
        {loadModule, scenario}
      end
      )
  end

  def deploy_modules(compiled_scenario, hosts) do
    {module, code} = compiled_scenario
    hosts
    |> Enum.map (fn host -> 
        task = Task.Supervisor.async({Shaker.Supervisor, host}, fn -> 
          if Code.ensure_compiled?(module) do
            {:already_defined, module, host}
          else
            [code] |> compile_scenarios
            {:ok, module, host}
          end
        end)

        Task.await(task)
      end)
  end

  @doc """
  invoke testcases.
  """
  def invoke_scenarios(scenario_locations, hosts, users \\ 1, loops \\ 1, case_timeout \\ 10000) do
    test_case_contents = scenario_locations |> read_scenarios |> compile_scenarios

    test_case_contents |> Enum.map(fn testcase -> deploy_modules(testcase, hosts) end)
    test_modules = test_case_contents |> Enum.map(fn {module, code} -> module end)

    start_time = :os.system_time(:millisecond)

    invoke_targets = case hosts do
                       [] -> [Node.self]
                       _ -> hosts
                     end


    host_length = length(invoke_targets)

    # invoke tests (scenario * loops * user)
    # scenario1  -- iteration 1 -- user 1
    #            |              |- user 2 
    #            |              |- user 3
    #            |              |_ user 4
    #            |- iteration 2
    #            |_ iteration 3
    # scenario2  -- iteration 1 -- user 1
    #            |              |- user 2 
    #            |              |- user 3
    #            |              |_ user 4
    #            |- iteration 2
    #            |_ iteration 3
    scenario_executors = test_modules  
    |> Task.async_stream(fn scenario -> 
      iterations = 1..loops |> Stream.map(fn iteration_count -> 
        tasks = 1..users |> Enum.map(fn x -> 
          invoke_host = Enum.at(invoke_targets, :rand.uniform(host_length) - 1)
          Task.Supervisor.async({Shaker.Supervisor, invoke_host}, fn -> 
            IO.puts("[#{:os.system_time(:millisecond) - start_time}] running #{scenario.name()}, iteration #{iteration_count}, user = #{x}...")
            # invoke scenarios
            result = scenario.run()
          end)
        end)
        results = Task.yield_many(tasks, case_timeout)
        results |> Enum.map(fn x -> {_, {:ok, res}} = x; res end) |> Enum.each(fn result -> 
          IO.puts("[#{:os.system_time(:millisecond) - start_time}] host=#{result.host}, name=#{result.name}, status = #{result.status}, response_time = #{result.response_time}")
        end)
      end)

      Stream.run(iterations)
    end, [timeout: :infinity])

    Stream.run(scenario_executors)
  end

  def invoke(%Shaker.CLI.Parser.Arguments.Master{} = arguments) do
    scenarios = arguments.scenarios |> extract_scenario_locations
    if length(scenarios) == 0 do
      IO.puts(:stderr, "failed to load scenarios. please apply the collect path (-s, --scenarios)")
      exit(:shutdown)
    end

    "shaker@127.0.0.1" |> String.to_atom |> Node.start

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

    invoke_scenarios(scenarios, arguments.hosts, arguments.parallel, arguments.loop, arguments.timeout)
  end

  def invoke(%Shaker.CLI.Parser.Arguments.Slave{} = arguments) do
    # launch slave mode
    launch_supervisor()
    arguments.node_name |> Node.start
    :timer.sleep(:infinity)
  end

  def invoke(arguments) do
    raise ArgumentError, message: "got invalid arguments"
  end

  @doc """
  entrypoint
  """
  def main(args) do
    args |> Shaker.CLI.Parser.parse |> invoke
  end
end
