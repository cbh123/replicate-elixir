defmodule Client do
  @moduledoc """
  Documentation for the Client
  """
  @host "https://api.replicate.com"

  defp header() do
    [
      Authorization: "Token #{Application.fetch_env!(:replicate, :replicate_api_token)}",
      "Content-Type": "application/json"
    ]
  end

  def request(method, path, body \\ nil) do
    case HTTPoison.request!(method, "#{@host}#{path}", body, header()) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, body |> Jason.decode!()}

      %HTTPoison.Response{status_code: 201, body: body} ->
        {:ok, body |> Jason.decode!()}

      %HTTPoison.Response{body: body} ->
        detail = Jason.decode!(body)["detail"]
        {:error, detail}
    end
  end
end
