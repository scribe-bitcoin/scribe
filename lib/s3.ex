defmodule Scribex.S3 do
  alias AWS.S3
  require Logger

  @bucket "chaincode-btc"

  def list_by_prefix(prefix) do
    Scribex.client()
    |> S3.list_objects_v2(@bucket, nil, nil, nil, nil, nil, prefix)
    |> handle_response()
  end

  def get_object(prefix) do
    Scribex.client()
    |> S3.get_object(@bucket, prefix)
    |> handle_response()
  end

  def handle_response(
        {:ok, %{"ListBucketResult" => %{"Contents" => results}}, %{status_code: 200}}
      ) do
    {:ok, Enum.map(results, fn i -> Map.take(i, ["Key", "LastModified"]) end)}
  end

  def handle_response({:ok, %{"Body" => body}, %{status_code: 200}}) do
    {:ok, body}
  end

  def handle_response({:ok, response, %{status_code: code}}) do
    Logger.info("Received status code #{code} response: " <> response)
    {:ok, response}
  end

  def handle_response({:error, {:unexpected_response, %{status_code: code, body: body}}}),
    do: {:error, "Code #{code}: #{body}"}

  def handle_response({:error, _} = err), do: err
end
