defmodule Scribex.S3 do
  alias AWS.S3
  require Logger

  @bucket "scribebtc-outputs"

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

  def to_s3uri(full_path) do
    if String.starts_with?(full_path, "s3://") do
      full_path
    else
      Path.join(["s3://", full_path])
    end
  end

  def to_s3uri(bucket_name, prefix) do
    Path.join(["s3://", bucket_name, prefix])
  end

  def from_s3uri(s3uri) do
    case String.split(s3uri, "//", parts: 2) do
      [_, path] -> String.split(path, "/", parts: 2)
      _ -> {:error, "not an S3 URI."}
    end
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
