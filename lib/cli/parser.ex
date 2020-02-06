defmodule Shaker.CLI.Parser do

  defmodule Arguments.Master do
    defstruct [
      parallel: 1,
      verbose: false,
      hosts: [Node.self],
      scenarios: "",
      loop: 1,
      timeout: 10_000
    ]
  end

  defmodule Arguments.Slave do
    defstruct [
      node_name: ""
    ]
  end

  defp default_val(value, initial) do
    case value do
      nil -> initial
      _ -> value
    end
  end

  def parse(args) do
    {result, _, _} = 
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
        ]
      )
    
    if result[:slave] do
      %Arguments.Slave {
        node_name: result[:node] |> default_val("slave") |> String.to_atom
      }
    else
      hosts = 
        case result[:hosts] do
          nil -> []
          value -> value |> OptionParser.split |> Enum.map(&(String.to_atom(&1)))
        end
      %Arguments.Master {
        parallel: result[:parallel] |> default_val(1),
        verbose: result[:verbose] |> default_val(false),
        hosts: hosts,
        scenarios: result[:scenarios] |> default_val(""),
        loop: result[:loop] |> default_val(1),
        timeout: result[:timeout] |> default_val(10_000)
      }
    end
  end
end