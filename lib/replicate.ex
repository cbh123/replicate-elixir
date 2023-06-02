defmodule Replicate do
  @moduledoc ~S"""
  This is the Official Elixir client for [Replicate](https://replicate.com).
  It lets you run models from your Elixir code, and do various other things on Replicate.
  """

  alias Replicate.Predictions
  alias Replicate.Predictions.Prediction

  @doc """
  Synchronously run a prediction in the format owner/name:version. Returns the output.

  You can also use `Replicate.Predictions.create` and `Replicate.Predictions.wait` directly.

  ## Examples

  ```
  iex> Replicate.run("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")
  ["https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"]
  ```
  """
  def run(model_version, input) do
    %{"model" => model_string, "version" => version_string} =
      Regex.named_captures(~r/^(?P<model>[^\/]+\/[^:]+):(?P<version>.+)$/, model_version)

    model = Replicate.Models.get!(model_string)
    version = Replicate.Models.get_version!(model, version_string)

    with {:ok, %Prediction{} = prediction} <- Predictions.create(version, input),
         {:ok, %Prediction{output: output}} <- Predictions.wait(prediction) do
      output
    else
      {:error, message} -> {:error, message}
    end
  end
end
