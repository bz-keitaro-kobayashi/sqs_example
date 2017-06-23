defmodule SqsExample.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = for i <- 0..20 do
      worker(SqsExample.SQSConsumer, [i, 'example-queue'], id: :"sqs_#{i}")
    end

    children = children ++ [
      worker(SqsExample.DoneManager, [])
    ]

    children = children ++ for i <- 0..5 do
      worker(SqsExample.SQSConsumer, [i, 'example-dlq'], id: :"dlq_#{i}")
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SqsExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
