defmodule SampleWebSocketScenario do
  use Shaker.Scenario

  def case do
    socket = Socket.Web.connect!("echo.websocket.org")
    socket |> Socket.Web.send!({ :text, "hello my charms" })
    socket |> Socket.Web.recv!
    socket |> Socket.Web.ping!
    socket |> Socket.Web.recv!
    "Hello"
  end
end