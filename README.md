# Replicate

The official Elixir client for [Replicate](https://replicate.com). It lets you run models from your Elixir code, and everything else you can do with Replicate's HTTP API.


## Installation

Install by adding `replicate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:replicate, "~> 1.1.0"}
  ]
end
```

## Demo
Want to jump right in to building your own apps with Elixir and Replicate? Check out 🔮 [Conjurer](https://github.com/cbh123/getting-started-with-replicate-elixir/blob/main/README.md), a simple demo app we built with the Elixir client.

<video width="400" controls>
  <source src="https://user-images.githubusercontent.com/14149230/242976273-dba6b2a0-71f1-4838-bf97-6937e3211efe.mp4" type="video/mp4">
</video>


## Authenticate

After installation, you need to set your Replicate API token in your environment.

Grab your token from [replicate.com/account](https://replicate.com/account) and set it as an environment variable:

```
export REPLICATE_API_TOKEN=<your token>
```

And run `source .env`.


Then, add the config to your `config.exs`:

```elixir
config :replicate,
  replicate_api_token: System.get_env("REPLICATE_API_TOKEN")

```

Now you can use `Replicate` to do cool machine learny stuff.

> 🚨 We recommend not adding the token directly to your source code, because you don't want to put your credentials in source control. If anyone used your API key, their usage would be charged to your account.

## Run a model

You can run a model synchronously:

```elixir
iex> Replicate.run("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a watercolor of the babadook by Picasso")
["https://replicate.delivery/pbxt/LgZ5BLmMWzqODp4rzSERXDNglStBTltHpj0533i9385qSgQE/out-0.png"]
```

## Run a model in the background

You can start a model and run it in the background with `Replicate.Predictions.create/5`:
```elixir
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> prediction.status
  "starting"
```

We can take a look at the prediction:
```elixir
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
```

Get the latest status of the prediction with `Replicate.Predictions.get/1`:
```elixir
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
```

And wait for completion with `Replicate.Predictions.wait/1`:
```elixir
  iex> {:ok, prediction} = Replicate.Predictions.wait(prediction)
  iex> prediction.status
  "succeeded"
  iex> prediction.output
  ["https://replicate.delivery/pbxt/xbT582euzFwqCiupR5PVyMUFemfgZHbPyAm5kenezBS3RDQIC/out-0.png"]
```

## Run a model in the background and get a webhook

You can run a model and get a webhook when it completes, instead of waiting for it to finish:

```
Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"}, "https://example.com/webhook", ["completed"])
```

If you want to see a demo of how to use webhooks in production, check out 🔮 [Conjurer](https://github.com/cbh123/getting-started-with-replicate-elixir/blob/main/README.md).


## Cancel a prediction

You can cancel a running prediction by passing an id or `%Replicate.Predictions.Prediction{}` to `Replicate.Predictions.cancel/1`:

```
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "Watercolor painting of the Babadook"})
  iex> prediction.status
  "starting"
  iex> {:ok, prediction} = Replicate.Predictions.cancel(prediction.id)
  iex> prediction.status
  "canceled"

  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> version = Replicate.Models.get_version!(model, "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf")
  iex> {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: "a 19th century portrait of a wombat gentleman"})
  iex> {:ok, prediction} = Replicate.Predictions.cancel(prediction)
  iex> prediction.status
  "canceled"
```

## List predictions

You can list all the predictions you've run:

```elixir
iex> Replicate.Predictions.list()
[%Prediction{
id: "1234",
status: "starting",
input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
output: ["https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"]
},
%Prediction{
id: "1235",
status: "starting",
input: %{"prompt" => "a 19th century portrait of a wombat gentleman"},
version: "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
output: ["https://replicate.com/api/models/stability-ai/stable-diffusion/files/50fcac81-865d-499e-81ac-49de0cb79264/out-0.png"]}
]
```

## List versions of a model

You can list all the versions of a model:

```elixir
  iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
  iex> versions = Replicate.Models.list_versions(model)
  iex> Replicate.Models.list_versions(model) |> Enum.map(& &1.id) |> Enum.slice(0..5)
    ["db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf",
    "328bd9692d29d6781034e3acab8cf3fcb122161e6f5afb896a4ca9fd57090577",
    "f178fa7a1ae43a9a9af01b833b9d2ecf97b1bcb0acfd2dc5dd04895e042863f1",
    "0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966",
    "27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
    "8abccf52e7cba9f6e82317253f4a3549082e966db5584e92c808ece132037776"]
```

## Get latest version of a model

*ELIXIR CLIENT EXCLUSIVE*

Gets the latest version of a model. Raises an error if the version doesn't exist.

```
iex> model = Replicate.Models.get!("stability-ai/stable-diffusion")
iex> version = Replicate.Models.get_latest_version!(model)
iex> version.id
"db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
iex> version.cog_version
"0.6.0"
```

## Load output files

Output files are returned as HTTPS URLs. Here's one way to load files without any dependencies:

```elixir
iex> [url | _rest] = Replicate.run("stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", prompt: "a watercolor of the babadook by Picasso")
iex> url
"https://replicate.delivery/pbxt/LgZ5BLmMWzqODp4rzSERXDNglStBTltHpj0533i9385qSgQE/out-0.png"
iex> {:ok, resp} = :httpc.request(:get, {url, []}, [], [body_format: :binary])
iex> {{_, 200, 'OK'}, _headers, body} = resp
iex> File.write!("babadook_watercolor.jpg", body)
```

# replicate-elixir
