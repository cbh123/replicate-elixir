defmodule Replicate.Client.Behaviour do
  @moduledoc """
  Documentation for the Client Behaviour
  """
  @callback request(method :: atom(), path :: String.t(), body :: map()) ::
              {:ok, String.t()} | {:error, String.t()}
end
