defmodule Replicate.Hardware do
  @moduledoc """
  Documentation for `Hardware`.
  """
  @behaviour Replicate.Hardware.Behaviour
  @replicate_client Application.compile_env(:replicate, :replicate_client, Replicate.Client)
  alias Replicate.Hardware
  alias Replicate.Hardware.Hardware

  @doc """
  Lists all hardware.

  Returns [Hardware.t()].

  ## Examples

  ```
  iex> Replicate.Hardware.list()
  [%Hardware{
    name: "CPU",
    sku: "cpu"
  },
  %Hardware{
    name: "Nvidia T4 GPU",
    sku: "gpu-t4"
  },
  %Hardware{
    name: "Nvidia A40 GPU",
    sku: "gpu-a40-small"
  },
  %Hardware{
    name: "Nvidia A40 (Large) GPU",
    sku: "gpu-a40-large"
  }
  ]
  ```
  """
  def list() do
    {:ok, results} = @replicate_client.request(:get, "/v1/hardware")

    results
    |> Jason.decode!()
    |> Enum.map(fn h ->
      atom_map = string_to_atom(h)
      struct!(Hardware, atom_map)
    end)
  end

  defp string_to_atom(body) do
    for {k, v} <- body, into: %{}, do: {String.to_atom(k), v}
  end
end
