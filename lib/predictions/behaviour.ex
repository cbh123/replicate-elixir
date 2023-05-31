defmodule Replicate.Predictions.Behaviour do
  @moduledoc """
  Documentation for the Predictions Behaviour
  """
  alias Replicate.Predictions.Prediction

  @callback get(id :: String.t()) ::
              {:ok, Prediction.t()} | {:error, String.t()}
  @callback get!(id :: String.t()) :: Prediction.t()
  @callback create(
              model_version :: String.t(),
              input :: %{string: any},
              webhook :: list(String.t()),
              webhook_completed :: list(String.t()),
              webook_event_filter :: list(String.t())
            ) :: {:ok, Prediction.t()} | {:error, String.t()}
end
