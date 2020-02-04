defmodule Shaker do
  def parser(args) do
    args |>
    OptionParser.parse(
      strict: [
        parallel: :integer, 
        verbose: :boolean,
        hosts: :string,
        scenarios: :string,
        loop: :integer
      ],
      aliases: [
        p: :parallel, 
        v: :verbose,
        h: :hosts,
        s: :scenarios,
        l: :loop
      ])
  end

  def load_scenarios(scenario_location) do
    case scenario_location do
      nil -> []
      _ -> Path.wildcard(scenario_location)
    end
  end

  def invoke_scenarios(scenarios, users \\ 5, loops \\ 5) do
    compiled_scenarios = scenarios |> Enum.map(
      fn (scenario) ->
        {{:module, loadModule, _, _}, _} = Code.eval_file(scenario)
        loadModule
      end)

    # invoke tests per (scenario * user * loops)
    executors = Stream.map(1..loops, fn i ->
      stream = compiled_scenarios |> Task.async_stream(fn scenario ->
        tasks = 1..users |> Enum.map(fn x -> 
          Task.Supervisor.async({Shaker.Supervisor, Node.self}, fn -> 
            # insert some hooks
            scenario.case() 
            # insert some hooks
          end)
        end)

        Task.yield_many(tasks, 10000)
      end)

      Stream.run(stream)
    end)

    Stream.run(executors)
  end

  def launch_supervisor() do
    children = [
      {Task.Supervisor, name: Shaker.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def main(args) do
    {opts, word, _} = args |> parser
    
    scenarios = opts[:scenarios] |> load_scenarios
    if length(scenarios) == 0 do
      IO.puts(:stderr, "failed to load scenarios. please apply the collect path (-s, --scenarios)")
      exit(:shutdown)
    end

    scenarios |> load_scenarios
  end
end
