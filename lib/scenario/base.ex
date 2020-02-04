defmodule Shaker.Result do
  defstruct pid: 0, response_time: 0, status: 0, case_result: ""
end

defmodule Shaker.Scenario do

  defmacro __using__(_opts) do
    quote do
      def hello(name), do: "Hi, #{name}"

      def run() do
        start_timestamp = :os.system_time(:millisecond)
        result = case()
        end_timestamp = :os.system_time(:millisecond)

        %Shaker.Result{
          pid: System.get_pid,
          response_time: end_timestamp - start_timestamp,
          case_result: result
        }
      end
    end
  end
end