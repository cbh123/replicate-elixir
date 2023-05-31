defmodule Replicate.Predictions do
  @moduledoc """
  Documentation for `Predictions`.
  """
  @behaviour Replicate.Predictions.Behaviour
  @replicate_client Application.compile_env!(:replicate, __MODULE__)[:replicate_client]
  alias Replicate.Predictions.Prediction

  @doc """
  Gets a prediction by id.

  ## Examples

  iex> {:ok, prediction} = Replicate.Predictions.get("1234")
  iex> prediction.status
  "starting"

  iex> Replicate.Predictions.get("not_a_real_id")
  {:error, "Prediction not found"}
  """
  def get(id) do
    @replicate_client.request(:get, "/v1/predictions/#{id}")
    |> parse_response()
  end

  @doc """
  Gets a prediction by id and fails if it doesn't exist.

  ## Examples

  iex> prediction = Replicate.Predictions.get!("1234")
  iex> prediction.status
  "starting"
  """
  def get!(id) do
    case get(id) do
      {:ok, prediction} -> prediction
      {:error, message} -> raise message
    end
  end

  def create(
        model_version,
        input,
        webhook \\ nil,
        webhook_completed \\ nil,
        webhook_event_filter \\ nil
      ) do
    %{"model" => _model, "version" => version} =
      Regex.named_captures(~r/^(?P<model>[^\/]+\/[^:]+):(?P<version>.+)$/, model_version)

    webhook_parameters =
      %{
        "webhook" => webhook,
        "webhook_completed" => webhook_completed,
        "webhook_event_filter" => webhook_event_filter
      }
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Enum.into(%{})

    body =
      %{
        "version" => version,
        "input" => input |> Enum.into(%{})
      }
      |> Map.merge(webhook_parameters)
      |> Jason.encode!()

    @replicate_client.request(:post, "/v1/predictions", body)
    |> parse_response()
  end

  defp parse_response({:ok, json_body}) do
    body =
      json_body
      |> Jason.decode!()
      |> string_to_atom()

    {:ok, struct(Prediction, body)}
  end

  defp parse_response({:error, message}), do: {:error, message}

  defp string_to_atom(body) do
    for {k, v} <- body, into: %{}, do: {String.to_atom(k), v}
  end
end
