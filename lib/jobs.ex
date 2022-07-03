defmodule Scribex.Jobs do
  use Agent

  @valid_job_statuses [
    "SUBMITTED",
    "IN_PROGRESS",
    "COMPLETED",
    "COMPLETED_WITH_ERROR",
    "FAILED",
    "STOP_REQUESTED",
    "STOPPED"
  ]

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def add(key, %{"JobId" => _, "JobStatus" => status} = job) do
    if status in @valid_job_status do
      Agent.update(__MODULE__, fn state -> Map.put(state, key, job) end)
    end
  end

  def delete(key) do
    Agent.update(__MODULE__, fn state -> Map.delete(state, key) end)
  end
end
