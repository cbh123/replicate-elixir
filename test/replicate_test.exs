defmodule ReplicateTest do
  use ExUnit.Case
  import Mox
  alias Replicate.Predictions.Prediction
  doctest Replicate
  doctest Replicate.Predictions

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "new prediction" do
    assert Replicate.run(
             "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
             prompt: "a 19th century portrait of a wombat gentleman"
           ) ==
             {:ok,
              %Prediction{
                status: "starting",
                input: %{"prompt" => "a 19th century portrait of a wombat gentleman"}
              }}
  end
end
