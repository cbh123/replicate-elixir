defmodule Replicate.Versions.Version do
  @moduledoc """
  `Version` struct.
  """
  defstruct [:id, :created_at, :cog_version, :openapi_schema]
end
