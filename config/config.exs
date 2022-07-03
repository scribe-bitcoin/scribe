import Config

config :scribex,
  key: System.get_env("ACCESS_KEY"),
  secret: System.get_env("ACCESS_SECRET"),
  region: "us-west-2",
  client_token: System.get_env("CLIENT_TOKEN"),
  gh_token: System.get_env("GH_TOKEN")


config :tentacat,
  extra_headers: [{"Accept", "application/vnd.github+json"}],