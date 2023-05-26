defmodule Replicate.Predictions do
  @moduledoc """
  Documentation for `Predictions`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Replicate.Predictions.hello()
      :world

  """
  @host "https://api.replicate.com"

  def hello do
    :world
  end

  defp header() do
    # should be a struct
    [
      Authorization: "Token #{System.fetch_env!("REPLICATE_TOKEN")}",
      "Content-Type": "application/json"
    ]
  end

  def new(version, input) do
    body =
      Jason.encode!(%{
        "version" => version,
        "input" => input
      })

    case HTTPoison.post!(@host, body, header()) do
      %HTTPoison.Response{status_code: 201, body: body} ->
        {:ok, body}

      %HTTPoison.Response{body: body} ->
        detail = Jason.decode!(body)["detail"]
        {:error, detail}
    end
  end

  def get(prediction_id) do
    HTTPoison.get!("#{@host}/#{prediction_id}", header())
  end

  def cancel(prediction_id) do
    # todo
  end
end
