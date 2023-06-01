defmodule Replicate.Versions.Behaviour do
  @moduledoc """
  `Version` behaviour.

  list() returns all version of a model.
  """
  @callback list :: [Replicate.Versions.Version.t()]
end
