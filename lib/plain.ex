defmodule Plain do
  defp base_url, do: "https://core-api.uk.plain.com/graphql/v1"
  defp token, do: Application.get_env(:plain, :token)

  @createTenantMutation "mutations/upsertTenant.graphql" |> File.read!()
  @spec createTenant(String.t(), String.t(), String.t() | nil) :: {:ok, map()} | {:error, any()}
  def createTenant(identifier, name, url) do
    send_request(@createTenantMutation, %{
      "input" => %{
        "identifier" => %{
          "externalId" => identifier
        },
        "name" => name,
        "externalId" => identifier,
        "url" =>
          if url != nil do
            %{
              "value" => url
            }
          else
            nil
          end
      }
    })
  end

  @spec createTenant(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  def createTenant(identifier, name), do: createTenant(identifier, name, nil)

  @customerByIdQuery "queries/getCustomerById.graphql" |> File.read!()
  @spec getCustomerById(String.t()) :: {:ok, map()} | {:error, any()}
  def getCustomerById(customer_id) do
    send_request(@customerByIdQuery, %{"customerId" => customer_id})
  end

  @spec send_request(String.t(), map()) :: {:ok, map()} | {:error, any()}
  defp send_request(query, variables) do
    req =
      base_request()
      |> Req.merge(
        body:
          Jason.encode!(%{
            query: query,
            variables: variables
          })
      )
      |> Req.request()

    case req do
      {:ok, %Req.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          {:error, reason} ->
            {:error, reason}
        end

      {:ok, %Req.Response{status: 401}} ->
        {:error, "Unauthorized"}

      {:ok, %Req.Response{status: 403}} ->
        {:error, "Forbidden"}

      {:ok, %Req.Response{status: 500}} ->
        {:error, "Internal server error"}

      {:ok, %Req.Response{status: status}} ->
        {:error, status}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp base_request do
    Req.new(
      method: :post,
      url: base_url(),
      headers: [{"Content-Type", "application/json"}, {"Accept", "application/json"}],
      auth: {:bearer, token()}
    )
  end
end
