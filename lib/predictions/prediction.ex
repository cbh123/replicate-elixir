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
    :urls,
    :created_at,
    :started_at,
    :completed_at
  ]
end
