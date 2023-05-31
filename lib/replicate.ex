defmodule Replicate do
  @moduledoc """
  Documentation for `Replicate`.
  """

  @doc """
  Run a prediction in the format owner/name:version.

  ## Examples

  iex> {:ok, prediction} = Replicate.run("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")
  iex> prediction.status
  "starting"
  iex> prediction.version
  "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
  """
  alias Replicate.Predictions

  def run(version, input) do
    case Predictions.create(version, input) do
      {:ok, prediction} ->
        Predictions.wait(prediction)

      {:error, message} ->
        {:error, message}
    end
  end

  def async_run(version, input) do
    Replicate.Predictions.create(version, input)
  end
end
