defmodule Replicate.Deployments do
  @moduledoc """
  Documentation for `Predictions`.
  """
  @behaviour Replicate.Deployments.Behaviour
  @replicate_client Application.compile_env(:replicate, :replicate_client, Replicate.Client)
  alias Replicate.Deployments.Deployment
  alias Replicate.Models.Version
  alias Replicate.Predictions.Prediction

  @doc """
  Gets a deployment by name, in the format `owner/model-name`.

  ## Examples

  ```
  iex> {:ok, deployment} = Replicate.Deployments.get("test/model")
  iex> deployment.username
  "test"

  iex> Replicate.Predictions.get("not_a_real_id")
  {:error, "Not found"}
  ```
  """
  def get(name) do
    [owner, model_name] = String.split(name, "/")
    {:ok, %Deployment{username: owner, name: model_name}}
  end

  @doc """
  Create a new prediction with the deployment. The input parameter should be a map of the model inputs.

  ## Examples

  ```
  iex> {:ok, deployment} = Replicate.Deployments.get("test/model")
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Deployments.create_prediction(deployment, version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> prediction.status
  "starting"
  ```
  """
  def create_prediction(
        %Deployment{username: username, name: name},
        %Version{id: version_id},
        input,
        webhook \\ nil,
        webhook_completed \\ nil,
        webhook_event_filter \\ nil,
        stream \\ nil
      ) do
    webhook_parameters =
      %{
        "webhook" => webhook,
        "webhook_completed" => webhook_completed,
        "webhook_event_filter" => webhook_event_filter,
        "stream" => stream
      }
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Enum.into(%{})

    body =
      %{
        "version" => version_id,
        "input" => input |> Enum.into(%{})
      }
      |> Map.merge(webhook_parameters)
      |> Jason.encode!()

    @replicate_client.request(:post, "/v1/deployments/#{username}/#{name}/predictions", body)
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
