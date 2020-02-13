defmodule Shaker.Scenario.Executor do

  def launch_agent do
    IO.puts("launching Executor Agent...")
    {:ok, agent} = Agent.start_link(fn -> %{result: []} end)
    IO.puts("Agent launched at #{inspect agent}")
    agent
  end

  def invoke_case(invoke_host, scenario, context) do
    Task.Supervisor.async({Shaker.Supervisor, invoke_host}, fn -> 
      current_time = :os.system_time(:millisecond)
      IO.puts("running #{scenario.name()}, iteration #{context[:iteration]}, user = #{context[:user]}...")
      # invoke scenarios

      result = scenario.run(context ++ [start_time: current_time])
      result
    end)
  end

  def write_report(report_name, agent) do
    state = Agent.get(agent, fn state -> state end)
    case_results = state[:result]
    {:ok, fp} = File.open(report_name, [:write, :utf8])

    IO.binwrite(fp, "timestamp,name,host,status,pid,response_time,user,iteration,message\n")

    case_results |>
     Enum.sort(fn(x, y) -> x.case_finished < y.case_finished end)
     |> Enum.each(fn result -> 
          timestamp = result.case_finished
          status = result.status
          name = result.name
          host = result.host
          pid = result.pid
          response_time = result.response_time
          message = result.case_result
          user = result.context[:user]
          iteration = result.context[:iteration]
          IO.binwrite(fp, "#{timestamp},#{name},#{host},#{status},#{pid},#{response_time},#{user},#{iteration},#{message}\n")
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

    scenario_stream = 
      compiled_modules 
      |> Task.async_stream(fn scenario -> 
        iterations = 
          1..loops 
          |> Stream.map(fn iteration -> 
            tasks = 
            1..users |> Enum.map(fn user ->
              host = Enum.at(hosts, :rand.uniform(length(hosts)) - 1)
              invoke_case(host, scenario, [user: user, iteration: iteration])
            end)

            results = Task.yield_many(tasks, :infinity)
                      |> Enum.map(fn result -> { _, {:ok, case_result}} = result; case_result end)

            Agent.get_and_update(agent, fn state ->
              {state, %{state | result: state[:result] ++ results}}
            end)            
          end)

          Stream.run(iterations)
      end, [timeout: :infinity])
    
    IO.puts("start invoking #{length(compiled_scenarios)} scenarios ... ")

    Stream.run(scenario_stream)

    IO.puts("finish")

    IO.puts("write report to #{report_name} ...")

    report_name |> write_report(agent)
  end
end