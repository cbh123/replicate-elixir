defmodule Replicate.Models.Model do
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
    :latest_version
  ]
end
