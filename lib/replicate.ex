defmodule Replicate do
  @moduledoc """
  Documentation for `Replicate`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Replicate.hello()
      :world

  """
  @host "https://api.replicate.com"

  @doc """
  Run a prediction in the format owner/name:version.

  ## Examples

  iex> Replicate.run("stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478", input: "a 19th century portrait of a wombat gentleman")
  {:ok, %{"prediction_id" => "1234"}}
  """
  def run(version, input) do
    Replicate.Predictions.create(version, input)
  end
end
