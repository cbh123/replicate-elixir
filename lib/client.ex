defmodule Replicate.Client do
  @moduledoc """
  Documentation for the Client
  """
  @host "https://api.replicate.com"
  @behaviour Replicate.Client.Behaviour
  alias Replicate.Predictions.Prediction

  defp header() do
    [
      Authorization: "Token #{Application.fetch_env!(:replicate, :replicate_api_token)}",
      "Content-Type": "application/json"
    ]
  end

  def request(method, path, body \\ nil) do
    case HTTPoison.request!(method, "#{@host}#{path}", body, header()) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body = body |> Jason.decode!() |> string_to_atom()
        prediction = struct(Prediction, body)
        {:ok, prediction}

      %HTTPoison.Response{status_code: 201, body: body} ->
        body = body |> Jason.decode!() |> string_to_atom()
        prediction = struct(Prediction, body)
        {:ok, prediction}

      %HTTPoison.Response{body: body} ->
        detail = Jason.decode!(body)["detail"]
        {:error, detail}
    end
  end

  defp string_to_atom(body) do
    for {k, v} <- body, into: %{}, do: {String.to_atom(k), v}
  end
end
