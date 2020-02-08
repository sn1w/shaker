defmodule SampleMockCase2 do
  use Shaker.Scenario

  def case do
    :timer.sleep(1500)
    [status: 500, message: "mock ok"]
  end
end