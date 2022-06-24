defmodule Scribex do
  @moduledoc """
  Documentation for `Scribex`.
  """

  alias AWS.{Client, S3, Translate}

  @valid_languages []

  @doc """
  start an async translation job. 
  Pass an S3 URI as input, and options as a map.
  """
  def start_batch_job(input_s3_uri, params) do
    client()
    |> Translate.start_text_translation_job(input_s3_uri, params)
  end

  def run_batch_job(input, source_language, target_language) do
    
    start_batch_job(file, [])
  end

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

  def client() do
    key = System.get_env("ACCESS_KEY")
    secret = System.get_env("ACCESS_SECRET")
    Client.create(key, secret, "us-west-2")
  end

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
        },
      }
  end

  def parse_file_type(filepath) do
    ext = filepath
    |> String.split(".")
    |> Enum.at(1)

    case ext do
      "html" -> "text/html"
      "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "xlf"  -> "application/x-xliff+xml"
      _      -> "text/plain"
    end
  end

  def handle_response({:ok, response, %{status_code: 200}}) do: {:ok, response}

  def handle_response({:ok, response, %{status_code: code}}) do: {:error, "Code #{code}: #{response}"}

  def handle_response({:error, {:unexpected_response, %{status_code: code, body: body}}}) do: {:error, "Code #{code}: #{body}"}
end
