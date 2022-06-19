defmodule Scribex do
  @moduledoc """
  Documentation for `Scribex`.
  """

  alias AWS.{S3, Translate}

  @valid_languages []

  @doc """
  start an async translation job. 
  Pass an S3 URI as input, and options as a map.
  """
  def start_batch_job(input, opts) do
    client()
    |> Translate.start_text_translation_job(input, opts)
  end

  # take a file (local)
  # job args: lang from / to, terminology, output name

  def run_batch_job(input, lang_from, lang_to) do
    file = File.read!(input)
    start_batch_job(file, [])
  end

  def client() do
    key = System.get_env("ACCESS_KEY")
    secret = System.get_env("ACCESS_SECRET")
    AWS.S3.Client.create(key, secret, "us-west-2")
  end
end
