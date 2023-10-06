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
  iex> models = Replicate.Models.list()
  """
  def list() do
    case @replicate_client.request(:get, "/v1/models") do
      {:ok, response} ->
        %{"results" => results, "next" => next, "previous" => previous} = Jason.decode!(response)

        raise "add pagination https://github.com/replicate/replicate-javascript/blob/main/index.js#L230C6-L230C11"

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

  defp string_to_atom(body) do
    for {k, v} <- body, into: %{}, do: {String.to_atom(k), v}
  end
end
