defmodule Replicate.Predictions do
  @moduledoc """
  Documentation for `Predictions`.
  """

  @doc """
  Create a new prediction.
  """
  @replicate_client Application.compile_env!(:replicate, __MODULE__)[:replicate_client]

  def create(
        version,
        input,
        webhook \\ nil,
        webhook_completed \\ nil,
        webhook_event_filter \\ nil
      ) do
    [_model | [version | _]] = String.split(version, ":")

    body =
      %{
        "version" => version,
        "input" => input |> Enum.into(%{})
      }
      |> Jason.encode!()

    @replicate_client.request(:post, "/v1/predictions", body)
  end
end
