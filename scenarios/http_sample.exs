defmodule SampleHttpRequestScenario do
  use Shaker.Scenario

  def name do
    "Sample HTTP"
  end

  def case do
    headers = []
    options = []
    {:ok, response} = HTTPoison.get("https://httpbin.org", headers, options)

    [status: 200, message: response.body]
  end
end