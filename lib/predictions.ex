defmodule Replicate.Predictions do
  @moduledoc """
  Documentation for `Predictions`.
  """
  @behaviour Replicate.Predictions.Behaviour
  @replicate_client Application.compile_env!(:replicate, :replicate_client)
  alias Replicate.Predictions.Prediction

  @doc """
  Gets a prediction by id.

  ## Examples

  ```
  iex> {:ok, prediction} = Replicate.Predictions.get("1234")
  iex> prediction.status
  "succeeded"

  iex> Replicate.Predictions.get("not_a_real_id")
  {:error, "Not found"}
  ```
  """
  def get(id) do
    @replicate_client.request(:get, "/v1/predictions/#{id}")
    |> parse_response()
  end

  @doc """
  Gets a prediction by id and fails if it doesn't exist.

  ```
  ## Examples

  iex> prediction = Replicate.Predictions.get!("1234")
  iex> prediction.id
  "1234"

  iex> Replicate.Predictions.get!("not_a_real_id")
  ** (RuntimeError) Not found
  ```
  """
  def get!(id) do
    case get(id) do
      {:ok, prediction} -> prediction
      {:error, message} -> raise message
    end
  end

  @doc """
  Cancels a prediction by id. If a prediction is completed, it cannot be canceled.

  ## Examples

  ```
  iex> {:ok, prediction} = Replicate.Predictions.cancel("1234")
  iex> prediction.status
  "canceled"

  iex> {:ok, prediction} = Replicate.Predictions.create("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")
  iex> prediction.status
  "starting"
  iex> {:ok, prediction} = Replicate.Predictions.wait(prediction)
  iex> prediction.status
  "succeeded"
  # iex> {:ok, prediction} = Replicate.Predictions.cancel(prediction.id)
  # iex> prediction.status
  # "succeeded"
  ```
  """
  def cancel(id) do
    @replicate_client.request(:post, "/v1/predictions/#{id}/cancel")
    |> parse_response()
  end

  @doc """
  Creates a prediction. You can optionally provide a webhook to be notified when the prediction is completed.

  ## Examples

  ```
  iex> {:ok, prediction} = Replicate.Predictions.create("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")
  iex> prediction.status
  "starting"
  ```
  """
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

  @doc """
  Waits for a prediction to complete.

  ## Examples

  ```
  iex> {:ok, prediction} = Replicate.Predictions.create("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")
  iex> prediction.status
  "starting"
  iex> {:ok, prediction} = Replicate.Predictions.wait(prediction)
  iex> prediction.status
  "succeeded"
  ```
  """
  def wait(%Prediction{} = prediction), do: @replicate_client.wait({:ok, prediction})

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
