defmodule SampleMockCase do
  use Shaker.Scenario

  def case do
    :timer.sleep(1000)
    "mock ok"
  end
end