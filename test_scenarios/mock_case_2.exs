defmodule SampleMockCase2 do
  use Shaker.Scenario
  @behaviour Shaker.ScenarioBehaviour

  def name do
    "Shaker Sample Case 2"
  end

  def case do
    sleep_time = :rand.uniform(2000)
    :timer.sleep(sleep_time)
    
    [status: 200, message: "mock ok (#{sleep_time} ms)"]
  end
end