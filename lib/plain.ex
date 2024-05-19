defmodule Plain do
  defp base_url, do: "https://core-api.uk.plain.com/graphql/v1"
  defp token, do: Application.get_env(:plain, :token)

  @createOrUpdateTenantMutation "mutations/upsertTenant.graphql" |> File.read!()
  @spec createOrUpdateTenant(String.t(), String.t(), String.t() | nil) ::
          {:ok, map()} | {:error, any()}
  @doc """
  # Upserting tenants

  When upserting a tenant you need to specify an `externalId` which matches the id of the tenant in your own backend.

  For example if your product is structured in teams, then when creating a tenant for a team you’d use the team’s id as the `externalId`.

  To upsert a tenant you need the following permissions:
  - `tenant:read`
  - `tenant:create`
  """
  def createOrUpdateTenant(identifier, name, url) do
    send_request(@createOrUpdateTenantMutation, %{
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

  @spec createOrUpdateTenant(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  def createOrUpdateTenant(identifier, name), do: createOrUpdateTenant(identifier, name, nil)

  @addCustomerToTenantMutation "mutations/addCustomerToTenant.graphql" |> File.read!()
  @spec addCustomerToTenant(String.t(), list(String.t())) :: {:ok, map()} | {:error, any()}
  @doc """
  # Add customers to tenants

  You can add a customer to multiple tenants.

  When selecting the customer you can chose how to identify them. This SDK uses the customer’s plain id.

  For this mutation you need the following permissions:

  - `customer:edit`
  - `customerTenantMembership:create`
  """
  def addCustomerToTenant(customerId, tenantIds) do
    send_request(@addCustomerToTenantMutation, %{
      "input" => %{
        "customerIdentifier" => %{
          "customerId" => customerId
        },
        "tenantIdentifiers" => Enum.map(tenantIds, &%{"externalId" => &1})
      }
    })
  end

  @removeCustomerFromTenantMutation "mutations/addCustomerToTenant.graphql" |> File.read!()
  @spec removeCustomerFromTenant(String.t(), list(String.t())) :: {:ok, map()} | {:error, any()}
  @doc """
  # Remove customers from tenants

  You can remove customers from multiple tenants in one API call.

  When selecting the customer you can chose how to identify them. This SDK uses the customer’s plain id.

  For this mutation you need the following permissions:
  - `customer:edit`
  - `customerTenantMembership:delete`
  """
  def removeCustomerFromTenant(customerId, tenantIds) do
    send_request(@removeCustomerFromTenantMutation, %{
      "input" => %{
        "customerIdentifier" => %{
          "customerId" => customerId
        },
        "tenantIdentifiers" => Enum.map(tenantIds, &%{"externalId" => &1})
      }
    })
  end

  @createOrUpdateCustomerMutation "mutations/upsertCustomer.graphql" |> File.read!()
  @spec createOrUpdateCustomer(String.t(), String.t(), String.t(), String.t() | nil) ::
          {:ok, map()} | {:error, any()}
  @doc """
  # Upserting customers
  Creating and updating customers is handled via a single API called `upsertCustomer`. You will find this name in both the API and this SDK.

  When you upsert a customer, you define:
  1. The identifier: This is the field you’d like to use to select the customer and is one of
    - `emailAddress`: This is the customer’s email address. Within Plain email addresses are unique to customers.
    - `customerId`: This is Plain’s customer ID. Implicitly if you use this as an identifier you will only be updating the customer since the customer can’t have an id unless it already exists.
    - `externalId`: This is the customer’s id in your systems. If you previously set this it can be a powerful way of syncing customer details from your backend with Plain.
  2. The customer details you’d like to use if creating the customer.
  3. The customer details you’d like to update if the customer already exists.

  When upserting a customer you will always get back a customer or an error.

  ​
  ## Upserting a customer

  This operation requires the following permissions:
  - `customer:create`
  - `customer:edit`
  """
  def createOrUpdateCustomer(email, externalIdentifier, fullName, name) do
    send_request(@createOrUpdateCustomerMutation, %{
      "input" => %{
        "identifier" => %{
          "externalId" => externalIdentifier
        },
        "onCreate" => %{
          "externalId" => externalIdentifier,
          "fullName" => fullName,
          "shortName" =>
            if name != nil do
              name
            else
              nil
            end,
          "email" => %{
            "email" => email,
            "isVerified" => false
          }
        },
        "onUpdate" => %{
          "fullName" => %{
            "value" => fullName
          },
          "shortName" =>
            if name != nil do
              %{"value" => name}
            else
              nil
            end,
          "email" => %{
            "email" => email,
            "isVerified" => true
          },
          "externalId" => %{
            "value" => externalIdentifier
          }
        }
      }
    })
  end

  @customerByIdQuery "queries/getCustomerById.graphql" |> File.read!()
  @spec getCustomerById(String.t()) :: {:ok, map()} | {:error, any()}
  @doc """
  If you already have the ID of a customer from within Plain or one of our other endpoints you can fetch more details about them using getCustomerById in the SDK.

  These endpoints require the following permissions:
  - `customer:read`
  """
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
