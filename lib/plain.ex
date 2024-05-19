defmodule Plain do
  defp base_url, do: "https://core-api.uk.plain.com/graphql/v1"
  defp token, do: Application.get_env(:plain, :token)

  @customByIdQuery "queries/getCustomerById.graphql" |> File.read!()
  def getCustomerById(customer_id) do
    send_request(@customByIdQuery, %{"customerId" => customer_id})
  end

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
