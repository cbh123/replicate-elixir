defmodule Replicate.Deployments.Behaviour do
  @moduledoc """
  Documentation for the Deployment Behaviour.
  """
  alias Replicate.Deployments.Deployment

  @callback get(String.t()) :: {:ok, Deployment.t()} | {:error, String.t()}
  @callback create_prediction(
              Deployment.t(),
              input :: %{string: any},
              webhook :: list(String.t()),
              webhook_completed :: list(String.t()),
              webook_event_filter :: list(String.t()),
              stream :: boolean()
            ) ::
              {:ok, Replicate.Predictions.Prediction.t()} | {:error, String.t()}
end
