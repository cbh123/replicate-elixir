defmodule Replicate.Models.Version do
  @moduledoc """
  `Version` struct.
  """
  @type t :: %__MODULE__{
          id: String.t(),
          created_at: String.t(),
          cog_version: String.t(),
          openapi_schema: map()
        }

  defstruct [:id, :created_at, :cog_version, :openapi_schema]
end
