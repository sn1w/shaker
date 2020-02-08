defmodule Shaker.Scenario.Executor do

  def launch_agent do
    {:ok, agent} = Agent.start_link(fn -> %{result: []} end)
    IO.inspect(agent)
    agent
  end

  def invoke_case(invoke_host, scenario, context) do
    Task.Supervisor.async({Shaker.Supervisor, invoke_host}, fn -> 
      IO.puts("[#{:os.system_time(:millisecond) - context[:start_time]}] running #{scenario.name()}, iteration #{context[:iteration]}, user = #{context[:user]}...")
      # invoke scenarios
      result = scenario.run(context)
      result
    end)
  end

  def write_report(report_name, agent) do
    state = Agent.get(agent, fn state -> state end)
    case_results = state[:result]
    {:ok, fp} = File.open(report_name, [:write, :utf8])
    case_results |> Enum.each(fn result -> 
      timestamp = result.context[:start_time]
      status = result.status
      name = result.name
      pid = result.pid
      response_time = result.response_time
      user = result.context[:user]
      iteration = result.context[:iteration]
      IO.binwrite(fp, "#{timestamp},#{name},#{status},#{pid},#{response_time},#{user},#{iteration}\n")
    end)
    File.close(fp)
  end

  @moduledoc """
  provides functions related to invoke test cases.
  """
  def execute(compiled_scenarios, hosts, users, loops, report_name) do
    agent = launch_agent()
    # deploy
    compiled_scenarios |> Enum.each(fn scenario -> scenario |> Shaker.Module.deploy(hosts) end)

    compiled_modules = compiled_scenarios |> Enum.map(fn x -> { module, _ } = x; module end)
    scenarios = compiled_scenarios |> Enum.map(fn x -> { _, scenario } = x; scenario end)

    start_time = :os.system_time(:millisecond)

    scenario_stream = 
      compiled_modules 
      |> Task.async_stream(fn scenario -> 
        iterations = 
          1..loops 
          |> Stream.map(fn iteration -> 
            host = Enum.at(hosts, 0)
            tasks = 
            1..users |> Enum.map(fn user ->
              invoke_case(host, scenario, [user: user, iteration: iteration, start_time: start_time])
            end)

            results = Task.yield_many(tasks, :infinity)
                      |> Enum.map(fn result -> { _, {:ok, case_result}} = result; case_result end)

            Agent.get_and_update(agent, fn state ->
              {state, %{state | result: state[:result] ++ results}}
            end)            
          end)

          Stream.run(iterations)
      end, [timeout: :infinity])
    
    Stream.run(scenario_stream)
    report_name |> write_report(agent)
  end
end