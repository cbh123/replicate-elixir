defmodule Replicate.MockClient do
  @moduledoc """
  Documentation for the MockClient
  """
  alias Replicate.Predictions.Prediction

  def request(_method, _path, _body) do
    {:ok,
     %Prediction{
       status: "starting",
       input: %{"prompt" => "a 19th century portrait of a wombat gentleman"}
     }}
  end
end
