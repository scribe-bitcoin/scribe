defmodule Scribex do
  @moduledoc """
  Documentation for `Scribex`.
  """

  require Logger
  alias AWS.{Client, Translate}
  alias Scribex.{BatchRequest, InputDataConfig, OutputDataConfig}

  @valid_languages []
  @terminologyNames ["bitcoin_terminology"]

  @doc """
  run an async translation job.
  """
  def run_batch_job(input_s3_uri, output_s3_uri, source_language, target_language) do
    token = Application.get_env(:scribex, :client_token)

    request =
      %BatchRequest{}
      |> Map.put(:clientToken, token)
      |> Map.put(:dataAccessRoleArn, get_arn())
      |> Map.put(:inputDataConfig, InputDataConfig.new(input_s3_uri))
      |> Map.put(:outputDataConfig, OutputDataConfig.new(output_s3_uri))
      |> Map.put(:sourceLanguageCode, source_language)
      |> Map.put(:targetLanguageCodes, [target_language])
      |> Map.put(:terminologyNames, @terminologyNames)
      |> normalize_params()

    Logger.info(request)
    Translate.start_text_translation_job(client(), request)
  end

  @doc """
  Read a local file and translate it directly. Max 5000 bytes. 
  """
  def translate_file(filepath, source_language, target_language) do
    text = File.read!(filepath)

    params = %{
      "Text" => text,
      "SourceLanguageCode" => source_language,
      "TargetLanguageCode" => target_language
    }

    client()
    |> Translate.translate_text(params)
    |> handle_response()
  end

  def save_job(key, %{"JobStatus" => status} = job), do: Scribex.Jobs.add(key, job)

  def client() do
    key = Application.get_env(:scribex, :key)
    secret = Application.get_env(:scribex, :secret)
    region = Application.get_env(:scribex, :region)
    Client.create(key, secret, region)
  end

  defp random_string(len) do
    len
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
  end

  def get_arn(), do: System.get_env("ARN")

  def params(input_bucket_uri, output_bucket_uri, source_language, target_language) do
    %{
      "SourceLanguageCode" => source_language,
      "TargetLanguageCodes" => [target_language],
      "InputDataConfig" => %{
        #          "ContentType" => content_type,
        "S3Uri" => input_bucket_uri
      },
      "OutputDataConfig" => %{
        "S3Uri" => output_bucket_uri
      }
    }
  end

  def parse_file_type(filepath) do
    ext =
      filepath
      |> String.split(".")
      |> Enum.at(1)

    case ext do
      "html" -> "text/html"
      "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "xlf" -> "application/x-xliff+xml"
      _ -> "text/plain"
    end
  end

  def normalize_params(params) when is_map(params) do
    params
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> {capitalize_first(k), v} end)
    |> Enum.filter(fn {_k, v} -> !is_nil(v) end)
    |> Enum.into(%{})
  end

  defp capitalize_first(s) do
    key_string = Atom.to_string(s)

    cap =
      key_string
      |> String.first()
      |> String.capitalize()

    <<_f::size(8), rest::binary>> = key_string
    List.to_string([cap, rest])
  end

  def handle_response({:ok, response, %{status_code: 200}}), do: {:ok, response}

  def handle_response({:ok, response, %{status_code: code}}),
    do: {:error, "Code #{code}: #{response}"}

  def handle_response({:error, {:unexpected_response, %{status_code: code, body: body}}}),
    do: {:error, "Code #{code}: #{body}"}
end
