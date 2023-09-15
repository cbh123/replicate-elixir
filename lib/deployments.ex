defmodule Replicate.Deployments do
  @moduledoc """
  Documentation for `Predictions`.
  """
  @behaviour Replicate.Deployments.Behaviour
  alias Replicate.Deployments.Deployment
  @replicate_client Application.compile_env(:replicate, :replicate_client, Replicate.Client)

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
