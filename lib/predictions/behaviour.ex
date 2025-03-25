defmodule Replicate.Predictions.Behaviour do
  @moduledoc """
  Documentation for the Predictions Behaviour
  """
  alias Replicate.Predictions.Prediction

  @callback get(id :: String.t()) ::
              {:ok, Prediction.t()} | {:error, String.t()}
  @callback get!(id :: String.t()) :: Prediction.t()
  @callback cancel(id :: String.t() | Prediction.t()) ::
              {:ok, Prediction.t()} | {:error, String.t()}
  @callback list :: list(Prediction.t())
  @callback create(
              version :: Replicate.Models.Version.t(),
              input :: %{String.t() => any()},
              webhook :: list(String.t()),
              webhook_completed :: list(String.t()),
              webook_evenst_filter :: list(String.t())
            ) :: {:ok, Prediction.t()} | {:error, String.t()}
  @callback create(
              model :: String.t(),
              input :: %{String.t() => any()},
              webhook :: list(String.t()),
              webhook_completed :: list(String.t()),
              webook_events_filter :: list(String.t())
            ) :: {:ok, Prediction.t()} | {:error, String.t()}
end
