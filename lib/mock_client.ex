defmodule Replicate.MockClient do
  @moduledoc """
  A mock version of `Replicate.Client`. Only used for testing.
  """
  alias Replicate.Predictions.Prediction

  @stub_prediction %{
    id: "1234",
    status: "starting",
    input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
    version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
    output: [
      "https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"
    ]
  }

  def request(:get, "/v1/models/cbh123/babadook-diffusion/versions") do
    {:ok,
     Jason.encode!(%{
       "results" => [
         %{
           "id" => "v1",
           "created_at" => "2022-04-26T19:29:04.418669Z",
           "cog_version" => "0.3.0",
           "openapi_schema" => %{}
         },
         %{
           "id" => "v2",
           "created_at" => "2022-03-21T13:01:04.418669Z",
           "cog_version" => "0.3.0",
           "openapi_schema" => %{}
         }
       ]
     })}
  end

  def request(:get, path) do
    id = String.split(path, "/") |> List.last()
    get(id)
  end

  def request(:post, path), do: request(:post, path, [])

  def request(:get, path, _body) do
    id = String.split(path, "/") |> List.last()
    get(id)
  end

  def request(:post, path, _body) do
    if Path.basename(path) == "cancel" do
      {:ok, %{@stub_prediction | status: "canceled"} |> Jason.encode!()}
    else
      {:ok, @stub_prediction |> Jason.encode!()}
    end
  end

  def request(:fail, _path, _body), do: {:error, "Failed"}

  defp get("1234") do
    {:ok, %{@stub_prediction | status: "succeeded"} |> Jason.encode!()}
  end

  defp get(_id) do
    {:error, "Not found"}
  end

  def wait({:ok, _prediction}) do
    {:ok, struct(Prediction, %{@stub_prediction | status: "succeeded"})}
  end

  def wait({:error, message}), do: {:error, message}
end
