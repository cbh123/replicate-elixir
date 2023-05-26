defmodule ReplicateTest do
  use ExUnit.Case
  doctest Replicate
  doctest Replicate.Predictions

  test "greets the world" do
    assert Replicate.hello() == :world
  end

  test "new prediction" do
    assert Replicate.Predictions.hello() == :world
  end
end
