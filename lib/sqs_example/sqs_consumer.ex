defmodule SqsExample.SQSConsumer do
  use GenServer
  require Logger

  @queue_name 'example-queue'

  def start_link(id) do
    GenServer.start_link(__MODULE__, {:id, id})
  end

  ## Callbacks

  def init({:id, id}) do
    {:ok, conf} = :erlcloud_aws.profile(System.get_env("AWS_PROFILE") || "default")
    conf = :erlcloud_aws.service_config(:sqs, "ap-northeast-1", conf)

    send(self(), :poll)
    {:ok, %{conf: conf, id: id}}
  end

  def handle_info(:poll, %{conf: conf} = state) do
    [messages: msgs] = :erlcloud_sqs.receive_message(@queue_name, :all, 1, 30, 20, conf)
    case msgs do
      [msg | _] ->
        msg
        |> Enum.into(%{})
        |> parse_message
        |> process_message(state)
      [] -> nil
    end
    send(self(), :poll)
    {:noreply, state}
  end

  defp parse_message(%{body: body} = msg) do
    parsed_body = Poison.Parser.parse!(body)
    Map.put(msg, :parsed_body, parsed_body)
  end

  defp process_message(%{parsed_body: body, receipt_handle: receipt_handle}, state) do
    sleep_seconds = body["processing_time"]
    log("starting: #{inspect body["id"]} (takes #{sleep_seconds}s)", state)
    Process.sleep(sleep_seconds * 1000)
    log("done: #{inspect body["id"]}", state)
    delete_message(receipt_handle, state)
  end

  defp delete_message(receipt_handle, %{conf: conf}) do
    :ok = :erlcloud_sqs.delete_message(@queue_name, receipt_handle, conf)
  end

  defp log(str, %{id: id}) do
    Logger.debug("[#{id}] #{str}")
  end
end
