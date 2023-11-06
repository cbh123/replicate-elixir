defmodule Replicate.Hardware.Behaviour do
  @moduledoc """
  Documentation for the Hardware Behaviour
  """
  alias Replicate.Hardware.Hardware
  @callback list :: list(Hardware.t())
end
