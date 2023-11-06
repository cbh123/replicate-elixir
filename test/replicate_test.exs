defmodule ReplicateTest do
  use ExUnit.Case
  import Mox
  alias Replicate.Predictions.Prediction
  alias Replicate.Models.Model
  alias Replicate.Hardware.Hardware
  doctest Replicate
  doctest Replicate.Predictions
  doctest Replicate.Models
  doctest Replicate.Deployments
  doctest Replicate.Hardware

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "create prediction" do
    model = Replicate.Models.get!("stability-ai/stable-diffusion")

    version =
      Replicate.Models.get_version!(
        model,
        "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
      )

    {:ok, prediction} =
      Replicate.Predictions.create(version, %{
        prompt: "a 19th century portrait of a wombat gentleman"
      })

    assert prediction.version ==
             "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478"

    assert prediction.status == "starting"
    assert prediction.input == %{"prompt" => "a 19th century portrait of a wombat gentleman"}
    assert prediction.urls["get"] == "https://api.replicate.com/v1/predictions/1234"
    assert prediction.urls["cancel"] == "https://api.replicate.com/v1/predictions/1234/cancel"
  end

  test "create and wait prediction" do
    model = Replicate.Models.get!("stability-ai/stable-diffusion")

    version =
      Replicate.Models.get_version!(
        model,
        "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
      )

    {:ok, prediction} =
      Replicate.Predictions.create(version, %{
        prompt: "a 19th century portrait of a wombat gentleman"
      })

    {:ok, %Prediction{output: output}} = Replicate.Predictions.wait(prediction)

    assert output == [
             "https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"
           ]
  end

  test "run prediction" do
    assert Replicate.run(
             "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
             prompt: "a 19th century portrait of a wombat gentleman"
           ) == [
             "https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"
           ]
  end

  test "get a model" do
    %Replicate.Models.Model{owner: owner, name: name} =
      Replicate.Models.get!("replicate/hello-world")

    assert owner == "replicate"
    assert name == "hello-world"
  end

  test "get a model and versions" do
    model = Replicate.Models.get!("replicate/hello-world")
    versions = Replicate.Models.list_versions(model)

    first_version = Enum.at(versions, 0)
    assert first_version.id == "v1"
    assert first_version.cog_version == "0.3.0"
  end

  test "create a deployment prediction" do
    {:ok, deployment} = Replicate.Deployments.get("test/model")

    {:ok, prediction} =
      Replicate.Deployments.create_prediction(deployment, %{
        prompt: "a 19th century portrait of a wombat gentleman"
      })

    assert prediction.status == "starting"
  end

  test "list models" do
    %{next: next, previous: previous, results: results} = Replicate.Models.list()

    assert next ==
             "https://api.replicate.com/v1/trainings?cursor=cD0yMDIyLTAxLTIxKzIzJTNBMTglM0EyNC41MzAzNTclMkIwMCUzQTAw"

    assert previous == nil
    assert results |> length() == 25

    assert results |> Enum.at(0) ==
             %Replicate.Models.Model{
               url: "https://replicate.com/replicate/hello-world",
               owner: "replicate",
               name: "hello-world",
               description: "A tiny model that says hello",
               visibility: "public",
               github_url: "https://github.com/replicate/cog-examples",
               paper_url: nil,
               license_url: nil,
               run_count: 12345,
               cover_image_url: nil,
               default_example: nil,
               latest_version: %{
                 "cog_version" => "0.3.0",
                 "created_at" => "2022-03-21T13:01:04.418669Z",
                 "id" => "v2",
                 "openapi_schema" => %{}
               }
             }
  end

  test "paginate models" do
    stream = Replicate.paginate(&Replicate.Models.list/0)
    first_batch = stream |> Enum.at(0)

    assert first_batch |> length() == 25
  end

  test "create a model" do
    {:ok, model} =
      Replicate.Models.create(
        owner: "replicate",
        name: "babadook",
        visibility: "public",
        hardware: "gpu-a40-large"
      )

    assert model.owner == "replicate"
    assert model.name == "babadook"
    assert model.visibility == "public"

    {:error, message} =
      Replicate.Models.create(
        owner: "replicate",
        name: "babadook"
      )

    assert message == "A required parameter (owner/name/visiblity/hardware) is missing"
  end

  test "list hardware" do
    hardware = Replicate.Hardware.list()

    assert hardware |> length() == 4
    assert hardware |> Enum.at(0) == %Hardware{name: "CPU", sku: "cpu"}
  end
end
