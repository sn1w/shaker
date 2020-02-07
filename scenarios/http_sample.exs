defmodule SampleHttpRequestScenario do
  use Shaker.Scenario

  def case do
    {:ok, conn} = Mint.HTTP.connect(:http, "httpbin.org", 443)
    {:ok, conn, _} = Mint.HTTP.request(conn, "GET", "/", [], "")
    receive do message ->
      {:ok, _, _} = Mint.HTTP.stream(conn, message)
    end    
  end
end