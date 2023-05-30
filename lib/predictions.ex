defmodule Replicate.Predictions do
  @moduledoc """
  Documentation for `Predictions`.
  """
  defstruct [
    :id,
    :error,
    :input,
    :logs,
    :output,
    :status,
    :version,
    :started_at,
    :created_at,
    :completed_at
  ]

  @doc """
  Create a new prediction.
  """
  def create(
        version,
        input,
        webhook \\ nil,
        webhook_completed \\ nil,
        webhook_event_filter \\ nil
      ) do
    body =
      Jason.encode!(%{
        "version" => version,
        "input" => input |> Enum.into(%{})
      })

    Client.request(:post, "/v1/predictions", body)
  end
end
