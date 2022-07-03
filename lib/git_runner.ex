defmodule Scribe.GitRunner do
	
	alias Scribe.S3

	@local_repo_path ""

	def client() do
		Tentacat.Client.new(%{access_token: Application.get_env(:gh_token)})
	end

	def get_translation_from_s3(s3_uri) do
		with {:ok, body} <- S3.get_object(s3_uri) do
			body
		else
			{:error, msg} -> Logger.error(msg)
		end
	end

	def create_issue(s3_url, language, title) do
		body = %{
			title: "Review requested: #{title}",
			body: "A translation for the text #{title} has been generated [here](#{s3_url}).\n Please review and edit the text, and submit a PR with the edited text in this repository. Thanks!",
			labels: ["open for review", language]
		}
		Tentacat.Issues.create(client(), "scribe-bitcoin", "library", body)
	end
end