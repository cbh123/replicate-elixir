defmodule Replicate.Predictions do
  @moduledoc """
  Documentation for `Predictions`.
  """
  @behaviour Replicate.Predictions.Behaviour
  @replicate_client Application.compile_env(:replicate, :replicate_client, Replicate.Client)
  alias Replicate.Predictions.Prediction
  alias Replicate.Models.Version

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
  Cancels a prediction given an id or `%Prediction{}`.

  ## Examples

  ```
  iex> {:ok, prediction} = Replicate.Predictions.cancel("1234")
  iex> prediction.status
  "canceled"

  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> {:ok, prediction} = Replicate.Predictions.cancel(prediction)
  iex> prediction.status
  "canceled"
  ```

  If a prediction is completed, it cannot be canceled.
  ```
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
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
  def cancel(%Prediction{id: id}) do
    cancel(id)
  end

  def cancel(id) when is_binary(id) do
    @replicate_client.request(:post, "/v1/predictions/#{id}/cancel")
    |> parse_response()
  end

  @doc """
  Creates a prediction. You can optionally provide a webhook to be notified when the prediction is completed.

  The input parameter should be a map of the model inputs.

  ## Examples

  If you're calling an Official Model, you can provide the model name and version:
  ```
  iex> {:ok, prediction} = Replicate.Predictions.create("stability-ai/stable-diffusion-3", %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> prediction.status
  "starting"

  Otherwise, provide a `%Replicate.Models.Version{}` struct:
  ```
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> prediction.status
  "starting"
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"}, "https://example.com/webhook")
  iex> prediction.status
  "starting"
  ```
  """
  def create(
        model,
        input,
        webhook \\ nil,
        webhook_completed \\ nil,
        webhook_events_filter \\ nil,
        stream \\ nil
      ) do
    webhook_parameters =
      %{
        "webhook" => webhook,
        "webhook_completed" => webhook_completed,
        "webhook_events_filter" => webhook_events_filter,
        "stream" => stream
      }
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Enum.into(%{})

    send_to_replicate(model, input, webhook_parameters)
  end

  defp send_to_replicate(%Version{id: id}, input, webhook_parameters) do
    body =
      %{
        "version" => id,
        "input" => input |> Enum.into(%{})
      }
      |> Map.merge(webhook_parameters)
      |> Jason.encode!()

    @replicate_client.request(:post, "/v1/predictions", body)
    |> parse_response()
  end

  defp send_to_replicate(model, input, webhook_parameters) do
    [model_owner, model_name] = String.split(model, "/")

    body =
      %{
        "input" => input |> Enum.into(%{})
      }
      |> Map.merge(webhook_parameters)
      |> Jason.encode!()

    @replicate_client.request(:post, "/v1/models/#{model_owner}/#{model_name}/predictions", body)
    |> parse_response()
  end

  @doc """
  Waits for a prediction to complete.

  ## Examples

  ```
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> prediction.status
  "starting"
  iex> {:ok, prediction} = Replicate.Predictions.wait(prediction)
  iex> prediction.status
  "succeeded"
  ```
  """
  def wait(%Prediction{} = prediction), do: @replicate_client.wait({:ok, prediction})

  @doc """
  Lists all the predictions you've run.

  ## Examples

  ```
  iex> Replicate.Predictions.list()
  [%Prediction{
    id: "1234",
    status: "starting",
    input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
    version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
    output: ["https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"],
    urls: %{
      "get" => "https://api.replicate.com/v1/predictions/1234",
      "cancel" => "https://api.replicate.com/v1/predictions/1234/cancel",
    }
   },
   %Prediction{
    id: "1235",
    status: "starting",
    input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
    version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
    output: ["https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"],
    urls: %{
      "get" => "https://api.replicate.com/v1/predictions/1235",
      "cancel" => "https://api.replicate.com/v1/predictions/1235/cancel"
    }
  }]
  ```
  """
  def list() do
    case @replicate_client.request(:get, "/v1/predictions") do
      {:ok, results} ->
        %{"results" => versions} = Jason.decode!(results)

        versions
        |> Enum.map(fn v ->
          atom_map = string_to_atom(v)
          struct(Replicate.Predictions.Prediction, atom_map)
        end)

      {:error, message} ->
        raise message
    end
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
