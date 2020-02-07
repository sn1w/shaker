defmodule Shaker.Module do
  def compile(contents) do
    contents
    |> Enum.map(
      fn (scenario) -> 
        {{:module, loadModule, _, _}, _} = Code.eval_string(scenario)
        {loadModule, scenario}
      end
    )
  end

  def deploy(compiled_scenario, hosts) do
    {module, code} = compiled_scenario
    hosts
    |> Enum.map(fn (host) -> 
        task = Task.Supervisor.async({Shaker.Supervisor, host}, fn -> 
          if Code.ensure_compiled?(module) do
            {:already_defined, module, host}
          else
            [code] |> Shaker.Module.compile
            {:ok, module, host}
          end
        end)

        Task.await(task)
      end)
  end
end