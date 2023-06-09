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
  @stub_prediction2 %{
    id: "1235",
    status: "starting",
    input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
    version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
    output: [
      "https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"
    ]
  }

  @stub_version1 %{
    id: "v1",
    created_at: "2022-04-26T19:29:04.418669Z",
    cog_version: "0.3.0",
    openapi_schema: %{}
  }

  @stub_version2 %{
    id: "v2",
    created_at: "2022-03-21T13:01:04.418669Z",
    cog_version: "0.3.0",
    openapi_schema: %{}
  }

  @stub_model %{
    "url" => "https://replicate.com/replicate/hello-world",
    "owner" => "replicate",
    "name" => "hello-world",
    "description" => "A tiny model that says hello",
    "visibility" => "public",
    "github_url" => "https://github.com/replicate/cog-examples",
    "paper_url" => nil,
    "license_url" => nil,
    "run_count" => 12345,
    "cover_image_url" => nil,
    "latest_version" => @stub_version2
  }

  def request(:get, "/v1/predictions") do
    {:ok, %{"results" => [@stub_prediction, @stub_prediction2]} |> Jason.encode!()}
  end

  def request(:get, "/v1/models/replicate/hello-world/versions") do
    {:ok, %{"results" => [@stub_version1, @stub_version2]} |> Jason.encode!()}
  end

  def request(:get, "/v1/models/replicate/hello-world") do
    {:ok, @stub_model |> Jason.encode!()}
  end

  def request(:get, "/v1/models/stability-ai/stable-diffusion/versions") do
    {:ok, %{"results" => [@stub_version1, @stub_version2]} |> Jason.encode!()}
  end

  def request(:get, "/v1/models/replicate/hello-world/versions/v2") do
    {:ok, @stub_version2 |> Jason.encode!()}
  end

  def request(:get, "/v1/models/stability-ai/stable-diffusion") do
    {:ok, @stub_model |> Jason.encode!()}
  end

  def request(
        :get,
        "/v1/models/replicate/hello-world/versions/27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478"
      ) do
    {:ok, @stub_version1 |> Jason.encode!()}
  end

  def request(
        :get,
        "/v1/models/replicate/hello-world/versions/db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
      ) do
    {:ok, @stub_version2 |> Jason.encode!()}
  end

  def request(:get, "/v1/predictions/1234") do
    {:ok, %{@stub_prediction | status: "succeeded"} |> Jason.encode!()}
  end

  def request(:get, "/v1/predictions/not_a_real_id"), do: {:error, "Not found"}
  def request(:get, "/v1/models/cbh123/babadook-diffusion"), do: {:error, "Not found"}

  def request(:get, path), do: {:error, "Unexpected path in the mock client: #{path}"}

  def request(:post, path), do: request(:post, path, [])

  def request(:post, path, _body) do
    if Path.basename(path) == "cancel" do
      {:ok, %{@stub_prediction | status: "canceled"} |> Jason.encode!()}
    else
      {:ok, @stub_prediction |> Jason.encode!()}
    end
  end

  def request(:fail, _path, _body), do: {:error, "Failed"}

  def wait({:ok, _prediction}) do
    {:ok, struct(Prediction, %{@stub_prediction | status: "succeeded"})}
  end

  def wait({:error, message}), do: {:error, message}
end
