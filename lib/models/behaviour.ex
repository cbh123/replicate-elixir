defmodule Replicate.Models.Behaviour do
  @moduledoc """
  Documentation for the Model Behaviour
  """

  @type create_opts :: [
          owner: String.t(),
          name: String.t(),
          visibility: String.t(),
          hardware: String.t(),
          description: String.t(),
          github_url: String.t(),
          paper_url: String.t(),
          license_url: String.t(),
          cover_image_url: String.t()
        ]

  @callback get!(name :: String.t()) :: Replicate.Models.Model.t()
  @callback get(name :: String.t()) :: {:ok, Replicate.Models.Model.t()} | {:error, String.t()}
  @callback get_version!(Replicate.Models.Model.t(), version :: String.t()) ::
              Replicate.Models.Version.t()
  @callback get_latest_version!(Replicate.Models.Model.t()) :: Replicate.Models.Version.t()
  @callback list_versions(Replicate.Models.Model.t()) :: [Replicate.Models.Version.t()]
  @callback list() :: %{
              results: [Replicate.Models.Model.t()],
              next: String.t(),
              previous: String.t()
            }
  @callback create(create_opts) :: {:ok, Replicate.Models.Model.t()} | {:error, String.t()}
end
