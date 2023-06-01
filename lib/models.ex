defmodule Replicate.Models do
  @moduledoc """
  Documentation for `Models`.
  """
  @behaviour Replicate.Models.Behaviour
  @replicate_client Application.compile_env!(:replicate, :replicate_client)
  alias Replicate.Models.Model

  @doc """
  Gets a model from a username/modelname string.

  TODO: make sure model actually exists

  ## Examples

  iex> Replicate.Models.get!("cbh123/babadook-diffusion")
  %Model{username: "cbh123", name: "babadook-diffusion"}
  """
  def get!(name) do
    [username, name] = String.split(name, "/")

    @replicate_client.request(:get, "/v1/models/#{username}/#{name}")
    |> IO.inspect(label: "response")

    struct(Model, %{username: username, name: name})
  end

  @doc """
  Returns a list of all versions for a model.

  ## Examples

  iex> model = Replicate.Models.get!("replicate/hello-world")
  iex> versions = Replicate.Models.list_versions(model)
  iex> %Replicate.Versions.Version{id: id, cog_version: cog_version} = List.first(versions)
  iex> id
  "v1"
  iex> cog_version
  "0.3.0"
  """
  def list_versions(%Model{username: username, name: name}) do
    case @replicate_client.request(:get, "/v1/models/#{username}/#{name}/versions") do
      {:ok, results} ->
        %{"results" => versions} = Jason.decode!(results)

        versions
        |> Enum.map(fn v ->
          atom_map = string_to_atom(v)
          struct(Replicate.Versions.Version, atom_map)
        end)

      {:error, message} ->
        raise message
    end
  end

  defp string_to_atom(body) do
    for {k, v} <- body, into: %{}, do: {String.to_atom(k), v}
  end
end
