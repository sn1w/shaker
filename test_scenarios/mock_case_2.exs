defmodule SampleMockCase2 do
  use Shaker.Scenario

  def case do
    :timer.sleep(1500)
    "mock ok"
  end
end