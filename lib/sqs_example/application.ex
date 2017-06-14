defmodule SqsExample.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = for i <- 0..10 do
      worker(SqsExample.SQSConsumer, [i], id: :"sqs_#{i}")
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SqsExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
