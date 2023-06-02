import Config

config :replicate,
  replicate_client: Replicate.Client,
  replicate_poll_interval: 500,
  replicate_api_token: System.get_env("REPLICATE_API_TOKEN")

import_config "#{config_env()}.exs"
