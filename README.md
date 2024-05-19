# Plain

Library for commonly used requests with the [Plain](https://plain.com) API, similar to the [typescript SDK](https://github.com/team-plain/typescript-sdk)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `plain` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plain, "~> 0.1.0"}
  ]
end
```

## Docs
The docs can be found at <https://hexdocs.pm/plain>.

## Example
```ex
# config/config.exs
config :plain, token: "your_token_here"
```

```ex
Plain.getCustomerById(%{ customer_id: 'c_01GHC4A88A9D49Q30AAWR3BN7P' })
```
