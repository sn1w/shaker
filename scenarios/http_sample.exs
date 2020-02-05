defmodule SampleHttpRequestScenario do
  use Shaker.Scenario

  def case do
    {:ok, conn} = Mint.HTTP.connect(:http, "httpbin.org", 443)
    {:ok, conn, request_ref} = Mint.HTTP.request(conn, "GET", "/", [], "")
    receive do message ->
      {:ok, conn, responses} = Mint.HTTP.stream(conn, message)
    end    
  end
end