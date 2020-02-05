defmodule Shaker do
  def parser(args) do
    args |>
    OptionParser.parse(
      strict: [
        parallel: :integer, 
        verbose: :boolean,
        hosts: :string,
        scenarios: :string,
        loop: :integer,
        timeout: :integer
      ],
      aliases: [
        p: :parallel, 
        v: :verbose,
        h: :hosts,
        s: :scenarios,
        l: :loop,
        t: :timeout
      ])
  end

  def load_scenarios(scenario_location) do
    case scenario_location do
      nil -> []
      _ -> Path.wildcard(scenario_location)
    end
  end

  @doc """
  invoke testcases.
  """
  def invoke_scenarios(scenarios, users \\ 1, loops \\ 1, case_timeout \\ 10000) do
    compiled_scenarios = scenarios 
    |> Enum.map(
      fn (scenario) -> 
        {{:module, loadModule, _, _}, _} = Code.eval_file(scenario)
        loadModule
      end)

    start_time = :os.system_time(:millisecond)

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
    scenario_executors = Task.async_stream(compiled_scenarios, fn scenario -> 
      iterations = 1..loops |> Stream.map(fn iteration_count -> 
        tasks = 1..users |> Enum.map(fn x -> 
          Task.Supervisor.async({Shaker.Supervisor, Node.self}, fn -> 
            IO.puts("[#{:os.system_time(:millisecond) - start_time}] running #{scenario.name()}, iteration #{iteration_count}, user = #{x}...")
            # invoke scenarios
            result = scenario.run()
          end)
        end)
        results = Task.yield_many(tasks, case_timeout)
        results |> Enum.map(fn x -> {_, {:ok, res}} = x; res end) |> Enum.each(fn result -> 
          IO.puts("[#{:os.system_time(:millisecond) - start_time}] name=#{result.name}, status = #{result.status}, response_time = #{result.response_time}")
        end)
      end)

      Stream.run(iterations)
    end, [timeout: :infinity])

    Stream.run(scenario_executors)
  end

  @doc """
  launch supervisor using by tasks
  """
  def launch_supervisor() do
    children = [
      {Task.Supervisor, name: Shaker.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  entrypoint
  """
  def main(args) do
    {opts, word, _} = args |> parser
    
    scenarios = opts[:scenarios] |> load_scenarios
    if length(scenarios) == 0 do
      IO.puts(:stderr, "failed to load scenarios. please apply the collect path (-s, --scenarios)")
      exit(:shutdown)
    end

    scenarios |> invoke_scenarios(opts[:parallel], opts[:loop], opts[:timeout])
  end
end
