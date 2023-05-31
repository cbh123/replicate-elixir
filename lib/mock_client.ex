defmodule Replicate.MockClient do
  @moduledoc """
  Documentation for the MockClient
  """

  @stub_prediction %{
    id: "1234",
    status: "starting",
    input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
    version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478"
  }

  def request(:get, path) do
    id = String.split(path, "/") |> List.last()
    get(id)
  end

  def request(:post, _path), do: request(:post, nil, nil)

  def request(:get, path, _body) do
    id = String.split(path, "/") |> List.last()
    get(id)
  end

  def request(:post, _path, _body) do
    {:ok, @stub_prediction |> Jason.encode!()}
  end

  def get("1234") do
    {:ok, @stub_prediction |> Jason.encode!()}
  end

  def get(_id) do
    {:error, "Prediction not found"}
  end

  def get!("1234") do
    {:ok, @stub_prediction |> Jason.encode!()}
  end

  def get!(_id) do
    raise "Prediction not found"
  end
end
