defmodule Replicate.Models do
  @moduledoc """
  Documentation for `Models`.
  """
  @behaviour Replicate.Models.Behaviour
  @replicate_client Application.compile_env(:replicate, :replicate_client, Replicate.Client)
  alias Replicate.Models.Model

  @doc """
  Gets a model from a owner/name string. Raises an error if the model doesn't exist.

  ## Examples

  ```
  iex> %Model{owner: owner, name: name} = Replicate.Models.get!("replicate/hello-world")
  iex> owner
  "replicate"
  iex> name
  "hello-world"
  ```
  """
  def get!(name) do
    [username, name] = String.split(name, "/")

    {:ok, result} = @replicate_client.request(:get, "/v1/models/#{username}/#{name}")

    model = Jason.decode!(result) |> string_to_atom()
    struct(Model, model)
  end

  @doc """
  Gets a model from a owner/name string. Returns {:error, "Not found"} if the model doesn't exist.

  ## Examples

  ```
  iex> {:ok, %Model{owner: owner, name: name}} = Replicate.Models.get("replicate/hello-world")
  iex> owner
  "replicate"
  iex> name
  "hello-world"
  ```
  """
  def get(name) do
    [username, name] = String.split(name, "/")

    case @replicate_client.request(:get, "/v1/models/#{username}/#{name}") do
      {:ok, result} ->
        model = Jason.decode!(result) |> string_to_atom()
        {:ok, struct(Model, model)}

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Gets a version of a model. Raises an error if the version doesn't exist.

  ## Examples

  ```
  iex> model = Replicate.Models.get!("replicate/hello-world")
  iex> version = Replicate.Models.get_version!(model, "v2")
  iex> version.id
  "v2"
  ```
  """
  def get_version!(%Model{owner: owner, name: name}, version) do
    {:ok, result} =
      @replicate_client.request(:get, "/v1/models/#{owner}/#{name}/versions/#{version}")

    version = Jason.decode!(result) |> string_to_atom()
    struct(Replicate.Models.Version, version)
  end

  @doc """
  Gets the latest version of a model. Raises an error if the version doesn't exist.

  ## Examples

  ```
  iex> model = Replicate.Models.get!("replicate/hello-world")
  iex> version = Replicate.Models.get_latest_version!(model)
  iex> version.id
  "v2"
  ```
  """
  def get_latest_version!(%Model{latest_version: %{"id" => id}} = model) do
    model |> get_version!(id)
  end

  @doc """
  Returns a list of all versions for a model.

  ## Examples

  ```
  iex> model = Replicate.Models.get!("replicate/hello-world")
  iex> versions = Replicate.Models.list_versions(model)
  iex> %Replicate.Models.Version{id: id, cog_version: cog_version} = List.first(versions)
  iex> id
  "v1"
  iex> cog_version
  "0.3.0"
  ```
  """
  def list_versions(%Model{owner: owner, name: name}) do
    case @replicate_client.request(:get, "/v1/models/#{owner}/#{name}/versions") do
      {:ok, results} ->
        %{"results" => versions} = Jason.decode!(results)

        versions
        |> Enum.map(fn v ->
          atom_map = string_to_atom(v)
          struct(Replicate.Models.Version, atom_map)
        end)

      {:error, message} ->
        raise message
    end
  end

  @doc """
  Get a paginated list of all public models.

  ## Examples
  iex> %{next: next, previous: previous, results: results} = Replicate.Models.list()
  iex> next
  "https://api.replicate.com/v1/trainings?cursor=cD0yMDIyLTAxLTIxKzIzJTNBMTglM0EyNC41MzAzNTclMkIwMCUzQTAw"
  iex> previous
  nil
  iex> results |> length()
  25
  iex> results |> Enum.at(0)
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
  """
  def list() do
    case @replicate_client.request(:get, "/v1/models") do
      {:ok, response} ->
        %{"results" => results, "next" => next, "previous" => previous} = Jason.decode!(response)

        models =
          results
          |> Enum.map(fn m ->
            atom_map = string_to_atom(m)
            struct!(Model, atom_map)
          end)

        %{next: next, previous: previous, results: models}

      {:error, message} ->
        raise message
    end
  end

  @doc """
  Create a model.

  Args:
    owner: The name of the user or organization that will own the model.
    name: The name of the model.
    visibility: Whether the model should be public or private.
    hardware: The SKU for the hardware used to run the model. Possible values can be found by calling `Replicate.Hardware.list()`.
    description: A description of the model.
    github_url: A URL for the model's source code on GitHub.
    paper_url: A URL for the model's paper.
    license_url: A URL for the model's license.
    cover_image_url: A URL for the model's cover image.


  Returns {:ok, %Replicate.Models.Model{}} or {:error, message}.

  ## Examples
  iex> {:ok, model} = Replicate.Models.create(
  ...>   owner: "replicate",
  ...>   name: "hello-world",
  ...>   visibility: "public",
  ...>   hardware: "gpu-a40-large"
  ...> )
  iex> model.owner
  "replicate"
  """
  def create(opts) do
    with {:ok, owner} <- Keyword.fetch(opts, :owner),
         {:ok, name} <- Keyword.fetch(opts, :name),
         {:ok, visibility} <- Keyword.fetch(opts, :visibility),
         {:ok, hardware} <- Keyword.fetch(opts, :hardware) do
      description = Keyword.get(opts, :description, nil)
      github_url = Keyword.get(opts, :github_url, nil)
      paper_url = Keyword.get(opts, :paper_url, nil)
      license_url = Keyword.get(opts, :license_url, nil)
      cover_image_url = Keyword.get(opts, :cover_image_url, nil)

      body =
        %{
          "owner" => owner,
          "name" => name,
          "visibility" => visibility,
          "hardware" => hardware,
          "description" => description,
          "github_url" => github_url,
          "paper_url" => paper_url,
          "license_url" => license_url,
          "cover_image_url" => cover_image_url
        }

      case @replicate_client.request(:post, "/v1/models", body) do
        {:ok, result} ->
          model = Jason.decode!(result) |> string_to_atom()
          {:ok, struct(Model, model)}

        {:error, message} ->
          {:error, message}
      end
    else
      :error -> {:error, "A required parameter (owner/name/visiblity/hardware) is missing"}
    end
  end

  defp string_to_atom(body) do
    for {k, v} <- body, into: %{}, do: {String.to_atom(k), v}
  end
end
