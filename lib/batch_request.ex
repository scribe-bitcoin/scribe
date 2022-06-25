defmodule Scribex.BatchRequest do
  alias Scribex.{InputDataConfig, OutputDataConfig}

  @derive Jason.Encoder
  defstruct [
    :clientToken,
    :dataAccessRoleArn,
    :inputDataConfig,
    :jobName,
    :outputDataConfig,
    :sourceLanguageCode,
    :targetLanguageCodes,
    :terminologyNames
  ]

  @type t :: %__MODULE__{
          clientToken: String.t(),
          dataAccessRoleArn: String.t(),
          inputDataConfig: InputDataConfig.t(),
          jobName: String.t(),
          outputDataConfig: OutputDataConfig.t(),
          sourceLanguageCode: String.t(),
          targetLanguageCodes: list(),
          terminologyNames: list()
        }
end

defmodule Scribex.InputDataConfig do
  defstruct s3Uri: nil, contentType: "text/plain"
  @type t :: %__MODULE__{contentType: String.t(), s3Uri: String.t()}

  def new(s3Uri) do
    %__MODULE__{}
    |> Map.put(:s3Uri, Scribex.to_s3uri(s3Uri))
    |> Map.put(:contentType, Scribex.parse_file_type(s3Uri))
    |> Scribex.normalize_params()
  end
end

defmodule Scribex.OutputDataConfig do
  defstruct s3Uri: nil
  @type t :: %__MODULE__{s3Uri: String.t()}

  def new(s3Uri) do
    %__MODULE__{}
    |> Map.put(:s3Uri, Scribex.to_s3uri(s3Uri))
    |> Scribex.normalize_params()
  end
end
