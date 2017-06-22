defmodule SqsExample.SQSConsumer do
  use GenServer
  require Logger

  alias SqsExample.DoneManager

  def start_link(id, queue_name) do
    GenServer.start_link(__MODULE__, {:id, id, queue_name})
  end

  ## Callbacks

  def init({:id, id, queue_name}) do
    {:ok, conf} = :erlcloud_aws.profile(System.get_env("AWS_PROFILE") || "default")
    conf = :erlcloud_aws.service_config(:sqs, "ap-northeast-1", conf)

    send(self(), :poll)
    {:ok, %{conf: conf, id: id, queue_name: queue_name}}
  end

  def handle_info(:poll, %{conf: conf, queue_name: queue_name} = state) do
    [messages: msgs] = :erlcloud_sqs.receive_message(queue_name, :all, 1, 5, 20, conf)
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
    # IO.inspect msg
    parsed_body = Poison.Parser.parse!(body)
    Map.put(msg, :parsed_body, parsed_body)
  end

  defp process_message(%{parsed_body: body, receipt_handle: receipt_handle, message_id: message_id}, state) do
    should_log = do_process(body, state)

    delete_message(receipt_handle, state)

    if should_log == :ok do
      :ok = DoneManager.done!(message_id)
      {:ok, times} = DoneManager.done_count(message_id)
      log("done: #{inspect body["id"]} (processed #{times} times)", state)
    end
  end

  defp do_process(%{"id" => id, "processing_time" => sleep_seconds}, state) do
    log("starting: #{inspect id} (takes #{sleep_seconds}s)", state)
    Process.sleep(sleep_seconds * 1000)
    :ok
  end

  defp do_process(%{"warmup" => true}, _state) do
    :no_log
  end

  defp do_process(%{"ping" => true, "submitted_time" => time} = body, state) do
    now = NaiveDateTime.utc_now()
    {:ok, datetime} = NaiveDateTime.from_iso8601(time)
    diff_ms = NaiveDateTime.diff(now, datetime, :millisecond)

    comment = if body["comment"] do
      " (#{body["comment"]})"
    else
      ""
    end
    log("ping time #{diff_ms}ms#{comment}", state)
    :no_log
  end

  defp delete_message(receipt_handle, %{conf: conf, queue_name: queue_name}) do
    :ok = :erlcloud_sqs.delete_message(queue_name, receipt_handle, conf)
  end

  defp log(str, %{id: id, queue_name: queue_name}) do
    ex = if queue_name == 'example-dlq' do
      "DLQ"
    else
      "   "
    end
    id_s = String.pad_leading(to_string(id), 2, "0")
    Logger.debug("[#{id_s}] #{ex} #{str}")
  end
end
