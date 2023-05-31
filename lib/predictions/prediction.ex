defmodule Replicate.Predictions.Prediction do
  @moduledoc """
  `Prediction` struct.
  """
  defstruct [
    :id,
    :error,
    :input,
    :logs,
    :output,
    :status,
    :version,
    :started_at,
    :created_at,
    :completed_at
  ]
end
