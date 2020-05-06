use Mix.Config

# Configure your database
config :discuss, Discuss.Repo,
  username: "postgres",
  password: "alisa",
  database: "discuss_test",
  hostname: "localhost",
  template: "template0",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :discuss, DiscussWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :discuss, :path_to_identicon, "/tmp/images"