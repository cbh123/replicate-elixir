defmodule Replicate.Client do
  @moduledoc """
  Documentation for the Client
  """
  @host Application.compile_env(:replicate, :replicate_base_url, "https://api.replicate.com")
  @behaviour Replicate.Client.Behaviour
  @poll_interval Application.compile_env(:replicate, :replicate_poll_interval, 500)
  @timeout Application.compile_env(:replicate, :replicate_timeout, 60_000)

  alias Replicate.Predictions
  alias Replicate.Predictions.Prediction

  defp header() do
    token = Application.fetch_env!(:replicate, :replicate_api_token)

    [
      Authorization: "Token #{token}",
      "Content-Type": "application/json"
    ]
  end

  def request(method, path), do: request(method, path, [])

  def request(method, path, body) do
    case HTTPoison.request!(method, "#{@host}#{path}", body, header(),
           timeout: @timeout,
           recv_timeout: @timeout
         ) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, body}

      %HTTPoison.Response{status_code: 201, body: body} ->
        {:ok, body}

      %HTTPoison.Response{body: body} ->
        detail = Jason.decode!(body)["detail"]
        {:error, detail}
    end
  end

  def wait({:ok, %Prediction{id: id, status: status} = prediction}) do
    cond do
      status in ["starting", "processing"] ->
        Process.sleep(@poll_interval)

        Predictions.get(id)
        |> wait()

      true ->
        {:ok, prediction}
    end
  end

  def wait({:error, message}), do: {:error, message}
end
