defmodule SqsExample.DoneManager do
  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def done_count(id) do
    Agent.get(__MODULE__, fn(map) ->
      {:ok, Map.get(map, id, 0)}
    end)
  end

  def done!(id) do
    Agent.update(__MODULE__, fn(map) ->
      count = Map.get(map, id, 0)
      count = count + 1
      Map.put(map, id, count)
    end)
  end
end
