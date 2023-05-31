import Config

config :replicate, Replicate.Predictions, replicate_client: Replicate.Client

import_config "#{config_env()}.exs"
