defmodule Replicate.Models.Behaviour do
  @moduledoc """
  Documentation for the Model Behaviour
  """
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
end
