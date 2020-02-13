defmodule Shaker.Result do
  defstruct [
    pid: 0, 
    response_time: 0, 
    status: 0, 
    case_result: "", 
    name: "", 
    host: "",
    case_finished: 0,
    # fetch by metadata
    context: []
  ]
end

defmodule Shaker.ScenarioBehaviour do
  @callback name() :: string :: term

  @callback case() :: list 
end

defmodule Shaker.Scenario do
  defmacro __using__(_opts) do
    quote do

      def host() do
        Node.self
      end

      def run(context) do
        start_timestamp = :os.system_time(:millisecond)
        result = case()
        end_timestamp = :os.system_time(:millisecond)

        %Shaker.Result{
          name: name(),
          host: host(),
          pid: System.get_pid,
          case_finished: end_timestamp,
          response_time: end_timestamp - start_timestamp,
          status: result[:status],
          case_result: result[:message],
          context: context
        }
      end
    end
  end
end