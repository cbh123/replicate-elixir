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

  @impl true
  def request(method, path) when is_atom(method) and is_binary(path) do
    req()
    |> Req.merge(method: method, url: path)
    |> Req.request!()
    |> handle_resp()
  end

  @impl true
  def request(method, path, body) when is_atom(method) and is_binary(path) do
    req()
    |> Req.merge(method: method, url: path, body: body)
    |> Req.request!()
    |> handle_resp()
  end

  @impl true
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

  @impl true
  def wait({:error, message}), do: {:error, message}

  defp req() do
    token = Application.fetch_env!(:replicate, :replicate_api_token)

    Req.new(
      base_url: @host,
      headers: [Authorization: "Token #{token}", "Content-Type": "application/json"],
      connect_options: [timeout: @timeout],
      receive_timeout: @timeout,
      # The Replicate.Client.Behavior doesn't allow us to just decode the body, so we disable it and do it manually
      decode_body: false
    )
  end

  defp handle_resp(%Req.Response{status: status, body: body}) when status in [200, 201] do
    {:ok, body}
  end

  defp handle_resp(%Req.Response{body: body}) do
    detail =
      body
      |> Jason.decode!()
      |> then(& &1["detail"])

    {:error, detail}
  end
end
