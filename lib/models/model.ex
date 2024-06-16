defmodule Replicate.Models.Model do
  @type t :: %__MODULE__{
          url: String.t(),
          owner: String.t(),
          name: String.t(),
          description: String.t(),
          visibility: String.t(),
          github_url: String.t(),
          paper_url: String.t(),
          license_url: String.t(),
          run_count: integer(),
          cover_image_url: String.t(),
          default_example: String.t(),
          latest_version: Replicate.Models.Version.t(),
          created_at: String.t()
        }

  @moduledoc """
  `Model` struct.
  """
  defstruct [
    :url,
    :owner,
    :name,
    :description,
    :visibility,
    :github_url,
    :paper_url,
    :license_url,
    :run_count,
    :cover_image_url,
    :default_example,
    :latest_version,
    :created_at
  ]
end
