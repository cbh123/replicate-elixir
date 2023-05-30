defmodule Client do
  @moduledoc """
  Documentation for the Client
  """
  @host "https://api.replicate.com"

  defp header() do
    [
      Authorization: "Token #{System.fetch_env!("REPLICATE_TOKEN")}",
      "Content-Type": "application/json"
    ]
  end

  def request(method, path, body \\ nil) do
    case HTTPoison.request!(method, "#{@host}#{path}", body, header()) do
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
