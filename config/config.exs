# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

config :slot_sync, SlotSync.Application, dummy: true

config :slot_sync, SlotSync.WIW,
  http_adaptor: HTTPoison,
  key: {:system, :string, "WIW_KEY"}

config :slot_sync, SlotSync.Datadog,
  host: {:system, "STATSD_HOST"},
  port: {:system, :integer, "STATSD_PORT"},
  namespace: "slot_sync",
  module: DogStatsd

