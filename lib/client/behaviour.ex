defmodule Replicate.Client.Behaviour do
  @moduledoc """
  Documentation for the Client Behaviour
  """
  alias Replicate.Predictions.Prediction

  @callback request(method :: atom(), path :: String.t()) ::
              {:ok, String.t()} | {:error, String.t()}
  @callback request(method :: atom(), path :: String.t(), body :: map()) ::
              {:ok, String.t()} | {:error, String.t()}
  @callback wait({:ok, Prediction.t()}) :: {:ok, Prediction.t()} | {:error, String.t()}
end
