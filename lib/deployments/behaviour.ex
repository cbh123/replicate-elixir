defmodule Replicate.Deployments.Behaviour do
  @moduledoc """
  Documentation for the Deployment Behaviour.
  """
  alias Replicate.Deployments.Deployment

  @callback get(String.t(), String.t()) :: {:ok, Deployment.t()} | {:error, String.t()}
  @callback predictions(Deployment.t()) ::
              {:ok, [String.t()]} | {:error, String.t()}
end
