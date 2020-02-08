defmodule SampleMockCase do
  use Shaker.Scenario

  def case do
    :timer.sleep(1000)
    
    [status: 200, message: "mock ok"]
  end
end