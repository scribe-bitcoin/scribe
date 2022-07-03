defmodule Scribex.GitRunner do
  alias Scribex.S3
  require Logger

  @library_path Application.get_env(:scribex, :library_repo_path)

  def client() do
    Tentacat.Client.new(%{access_token: Application.get_env(:scribex, :gh_token)})
  end

  def repo(), do: Git.new(@library_path)

  def set_context() do
    repo = repo()
    Git.checkout!(repo, ["main"])
    Git.pull(repo, [])
  end

  def push_new_translation(s3_prefix) do
    repo = repo()

    with {:ok, body} <- S3.get_object(s3_prefix) do
      {prefix, filepath} = create_repo_path(s3_prefix)
      create_branch(repo, prefix)
      File.write(filepath, body)
      Git.add(repo, ".")
      Git.commit(repo, ["-m", "Automatically created commit for adding file #{prefix}"])
      Git.push(repo, ["--set-upstream", "origin", prefix])
      {:ok, s3_prefix}
    else
      {:error, msg} -> Logger.error(msg)
    end
  end

  def create_issue(s3_prefix, language, title) do
    body = %{
      title: "Review requested: #{title}",
      body:
        "A translation for the text #{title} has been generated in [this branch](https://github.com/scribe-bitcoin/library/tree/#{s3_prefix}).\n Please review and edit the text, and submit a PR with the edited text in this repository. Thanks!",
      labels: ["open for review", language]
    }

    Tentacat.Issues.create(client(), "scribe-bitcoin", "library", body)
  end

  def create_repo_path(prefix) do
    {prefix, Path.join([@library_path, prefix])}
  end

  def create_branch(repo, branchname) do
    case is_main_branch?(repo) do
      true -> Git.checkout(repo, ["-b", branchname])
      false -> switch_to_branch(repo, branchname)
    end
  end

  def is_main_branch?(repo) do
    repo
    |> Git.status!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.at(0)
    |> String.equivalent?("On branch main")
  end

  @doc """
  If the branch already exists, switch to it.
  If not, checkout to main, then checkout a fresh branch from there.
  """
  def switch_to_branch(repo, branchname) do
    case repo
         |> get_branches()
         |> Enum.any?(&String.equivalent?(&1, branchname)) do
      true ->
        Git.checkout(repo, [branchname])

      false ->
        Git.checkout(repo, "main")
        Git.checkout(repo, ["-b", branchname])
    end
  end

  def get_branches(repo) do
    repo
    |> Git.branch!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s -> String.trim(s, "* ") end)
  end
end
