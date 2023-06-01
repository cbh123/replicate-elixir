defmodule ReplicateTest do
  use ExUnit.Case
  import Mox
  alias Replicate.Predictions.Prediction
  alias Replicate.Models.Model
  doctest Replicate
  doctest Replicate.Predictions
  doctest Replicate.Models

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "create prediction" do
    {:ok, %Prediction{} = prediction} =
      Replicate.Predictions.create(
        "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
        prompt: "a 19th century portrait of a wombat gentleman"
      )

    assert prediction.status == "starting"
    assert prediction.input == %{"prompt" => "a 19th century portrait of a wombat gentleman"}

    assert prediction.version ==
             "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478"
  end

  test "create and wait prediction" do
    {:ok, %Prediction{} = prediction} =
      Replicate.Predictions.create(
        "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
        prompt: "a 19th century portrait of a wombat gentleman"
      )

    {:ok, %Prediction{output: output}} = Replicate.Predictions.wait(prediction)

    assert output == [
             "https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"
           ]
  end

  test "run prediction" do
    assert Replicate.run(
             "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
             prompt: "a 19th century portrait of a wombat gentleman"
           ) == [
             "https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"
           ]
  end
end
