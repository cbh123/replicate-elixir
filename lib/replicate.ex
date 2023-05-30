defmodule Replicate do
  @moduledoc """
  Documentation for `Replicate`.
  """

  @doc """
  Run a prediction in the format owner/name:version.

  ## Examples

  iex> Replicate.run("stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478", prompt: "a 19th century portrait of a wombat gentleman")
  {:ok, %{"status" => "starting"}}
  """

  def run(version, input) do
    Replicate.Predictions.create(version, input)
  end
end
