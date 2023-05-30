defmodule ReplicateTest do
  use ExUnit.Case
  doctest Replicate
  doctest Replicate.Predictions

  test "new prediction" do
    Replicate.run(
      "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
      input: "a 19th century portrait of a wombat gentleman"
    )
  end
end
