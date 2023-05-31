defmodule Replicate.Client do
  @moduledoc """
  Documentation for the Client
  """
  @host "https://api.replicate.com"
  @behaviour Replicate.Client.Behaviour

  defp header() do
    [
      Authorization: "Token #{Application.fetch_env!(:replicate, :replicate_api_token)}",
      "Content-Type": "application/json"
    ]
  end

  def request(method, path), do: request(method, path, [])

  def request(method, path, body) do
    case HTTPoison.request!(method, "#{@host}#{path}", body, header())
         |> IO.inspect(label: "prediction") do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, body}

      %HTTPoison.Response{status_code: 201, body: body} ->
        {:ok, body}

      %HTTPoison.Response{body: body} ->
        detail = Jason.decode!(body)["detail"]
        {:error, detail}
    end
  end
end
