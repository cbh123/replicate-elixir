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
  def run(version, input) do
    with {:ok, %Prediction{} = prediction} <- Predictions.create(version, input),
         {:ok, %Prediction{output: output}} <- Predictions.wait(prediction) do
      output
    else
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Asynchronously run a prediction. You can also use `Replicate.Predictions.create` directly.

  ## Examples

  ```
  iex> {:ok, prediction} = Replicate.async_run("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")
  iex> prediction.status
  "starting"
  ```
  """
  def async_run(version, input) do
    Predictions.create(version, input)
  end
end
