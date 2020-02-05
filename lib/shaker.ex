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
        timeout: :integer,
        # using slave mode
        slave: :boolean,
        node: :string
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
  def invoke_scenarios(scenarios, hosts, users \\ 1, loops \\ 1, case_timeout \\ 10000) do
    compiled_scenarios = 
      scenarios 
      |> Enum.map(
        fn (scenario_location) ->
          {:ok, content} = File.read(scenario_location)
          content
        end
      ) |> Enum.map(
        fn (scenario) -> 
          {{:module, loadModule, _, _}, _} = Code.eval_string(scenario)
          {loadModule, scenario}
        end)
    
    # Deploy modules to another node
    compiled_scenarios |> Enum.each(fn x -> 
      {mod, code} = x
      hosts |> Enum.each(fn host -> 
        task = Task.Supervisor.async({Shaker.Supervisor, host}, fn ->
          IO.inspect(Code.eval_string(code))
        end)
        Task.await(task)
      end)
    end)

    start_time = :os.system_time(:millisecond)

    host_length = length(hosts)

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
    scenario_executors = compiled_scenarios 
    |> Enum.map(fn x -> { mod, code } = x; mod end) 
    |> Task.async_stream(fn scenario -> 
      iterations = 1..loops |> Stream.map(fn iteration_count -> 
        tasks = 1..users |> Enum.map(fn x -> 
          invoke_host = Enum.at(hosts, :rand.uniform(host_length) - 1)
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

    if opts[:slave] == true do
      # launch slave mode
      launch_supervisor()
      opts[:node] |> String.to_atom |> Node.start
      :timer.sleep(:infinity)
    else
      scenarios = opts[:scenarios] |> load_scenarios
      if length(scenarios) == 0 do
        IO.puts(:stderr, "failed to load scenarios. please apply the collect path (-s, --scenarios)")
        exit(:shutdown)
      end

      "shaker@127.0.0.1" |> String.to_atom |> Node.start

      launch_supervisor()

      hosts = case opts[:hosts] do 
        nil -> [Node.self()]
        strings -> OptionParser.split(strings) |> Enum.map(fn x -> String.to_atom(x) end)
      end

      parallels = case opts[:parallel] do
        nil -> 1
        value -> value
      end

      iterations = case opts[:loop] do
        nil -> 1
        value -> value
      end

      timeout = case opts[:timeout] do
        nil -> 30000
        value -> value
      end

      # try to connect specified Node
      hosts |> Enum.each(fn host ->
        case Node.connect(host) do
          :ignored ->
            IO.puts(:stderr, "Failed to connect node, #{host}")
            exit(:shutdown)
          true ->
            IO.puts("Connection node #{host} successful")
        end
      end)

      invoke_scenarios(scenarios, hosts, parallels, iterations, timeout)
    end
  end
end
