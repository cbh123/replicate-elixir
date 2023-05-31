import Config

config :replicate, Replicate.Predictions,
  replicate_client: Replicate.MockClient,
  replicate_poll_interval: 500
