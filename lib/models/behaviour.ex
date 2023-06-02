defmodule Replicate.Models.Behaviour do
  @moduledoc """
  Documentation for the Model Behaviour
  """
  @callback get!(name :: String.t()) :: Replicate.Models.Model.t()
  @callback get(name :: String.t()) :: {:ok, Replicate.Models.Model.t()} | {:error, String.t()}
  @callback list_versions(Replicate.Models.Model.t()) :: [Replicate.Versions.Version.t()]
end
