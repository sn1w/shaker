defmodule SampleWebSocketScenario do
  use Shaker.Scenario

  def case do
    socket = Socket.Web.connect!("echo.websocket.org")
    socket |> Socket.Web.send!({ :text, "hello my charms" })
    socket |> Socket.Web.recv! |> IO.inspect
    socket
    |> Socket.Web.ping!
    socket 
    |> Socket.Web.recv! |> IO.inspect
    "Hello"
  end
end