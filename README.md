# Replicate

The official Elixir client for [Replicate](https://replicate.com). It lets you run models from your Elixir code, and everything else you can do with Replicate's HTTP API.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `replicate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:replicate, "~> 0.1.0"}
  ]
end
```

Or by commit reference:
```
def deps do
  [
    {:replicate, git: "https://github.com/cbh123/replicate-elixir", ref: "bc30d08"}
  ]
end
```

## Authenticate

Before running any Python scripts that use the API, you need to set your Replicate API token in your environment.

Grab your token from [replicate.com/account](https://replicate.com/account) and set it as an environment variable:

```
export REPLICATE_API_TOKEN=<your token>
```

> We recommend not adding the token directly to your source code, because you don't want to > put your credentials in source control. If anyone used your API key, their usage would be > charged to your account.

Then, add the config to your `config.exs`:

```elixir
config :replicate,
  replicate_api_token: System.get_env("REPLICATE_API_TOKEN")

```

## Run a model

Now you can use `Replicate`.

```elixir
iex> Replicate.run("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a 19th century portrait of a wombat gentleman")

["https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"]
```

## Run a model in the background

You can start a model and run it in the background with `Replicate.Predictions.create/5`:
```elixir
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> prediction.status
  "starting"
  iex> prediction
  %Replicate.Predictions.Prediction{
    id: "krdjxq6rw5bx3dopem52ohezca",
    error: nil,
    input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
    logs: "",
    output: nil,
    status: "starting",
    version: "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf",
    started_at: nil,
    created_at: "2023-06-02T20:43:55.720751299Z",
    completed_at: nil
  }
  iex> {:ok, prediction} = Replicate.Predictions.get(prediction.id)
  iex> prediction.logs |> String.split("\n")
    ["Using seed: 54144", "input_shape: torch.Size([1, 77])",
    "  0%|          | 0/50 [00:00<?, ?it/s]",
    "  6%|▌         | 3/50 [00:00<00:02, 21.14it/s]",
    " 12%|█▏        | 6/50 [00:00<00:02, 21.18it/s]",
    " 18%|█▊        | 9/50 [00:00<00:01, 21.20it/s]",
    " 24%|██▍       | 12/50 [00:00<00:01, 21.25it/s]",
    " 30%|███       | 15/50 [00:00<00:01, 21.21it/s]",
    " 36%|███▌      | 18/50 [00:00<00:01, 21.24it/s]",
    " 42%|████▏     | 21/50 [00:00<00:01, 21.23it/s]",
    " 48%|████▊     | 24/50 [00:01<00:01, 21.19it/s]",
    " 54%|█████▍    | 27/50 [00:01<00:01, 21.16it/s]",
    " 60%|██████    | 30/50 [00:01<00:00, 21.17it/s]",
    " 66%|██████▌   | 33/50 [00:01<00:00, 21.15it/s]",
    " 72%|███████▏  | 36/50 [00:01<00:00, 21.17it/s]",
    " 78%|███████▊  | 39/50 [00:01<00:00, 21.16it/s]",
    " 84%|████████▍ | 42/50 [00:01<00:00, 21.16it/s]",
    " 90%|█████████ | 45/50 [00:02<00:00, 21.16it/s]",
    " 96%|█████████▌| 48/50 [00:02<00:00, 20.99it/s]",
    "100%|██████████| 50/50 [00:02<00:00, 21.14it/s]",
    ""]
  iex> {:ok, prediction} = Replicate.Predictions.wait(prediction)
  iex> prediction.status
  "succeeded"
  iex> prediction.output
  ["https://replicate.delivery/pbxt/xbT582euzFwqCiupR5PVyMUFemfgZHbPyAm5kenezBS3RDQIC/out-0.png"]
```


  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"}, "https://example.com/webhook")
  iex> prediction.status
  "starting"

Then, you can `Replicate.Predictions.get/1` or `Replicate.Predictions.get!/1` the prediction:

```elixir
  iex> {:ok, prediction} = Replicate.Predictions.get("1234")
  iex> prediction.status
  "succeeded"
```

You can also use the handy `Replicate.Predictions.wait/1` which takes a prediction and doesn't return until success:

```elixir
  iex> {:ok, prediction} = Replicate.Predictions.wait(prediction)
  iex> prediction.status
  "succeeded"
```


You can start a model and run it in the background:

```elixir
model = Replicate.Models.get("kvfrans/clipdraw")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/replicate>.
# replicate-elixir
