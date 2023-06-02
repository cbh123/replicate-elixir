# Replicate

The official Elixir client for <a href="https://replicate.com">Replicate</a>. It lets you run models from your Elixir code, and everything else you can do with Replicate's HTTP API.


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

We recommend not adding the token directly to your source code, because you don't want to put your credentials in source control. If anyone used your API key, their usage would be charged to your account.

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

You can start a model and run it in the background:

```elixir
model = Replicate.Models.get("kvfrans/clipdraw")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/replicate>.
# replicate-elixir
