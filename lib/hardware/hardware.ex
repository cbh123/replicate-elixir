defmodule Replicate.Hardware.Hardware do
  @doc """
  Documentation for `Hardware`.
  """
  @enforce_keys [:sku, :name]
  defstruct [:sku, :name]
end
