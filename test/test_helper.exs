ExUnit.start()

Mox.defmock(Replicate.Client, for: Replicate.Client.Behaviour)
Application.put_env(:replicate, :replicate_client, Replicate.MockClient)
