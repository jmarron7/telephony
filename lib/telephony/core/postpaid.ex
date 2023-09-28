defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.Call
  alias Telephony.Core.Invoice

  defstruct balance: 0

  @price_per_minute 1.04

  def make_call(subscriber, call_duration, date) do
    subscriber
    |> update_balance(call_duration)
    |> add_call(call_duration, date)
  end

  defp update_balance(%{subscriber_type: subscriber_type} = subscriber, call_duration) do
    charge = call_duration * @price_per_minute
    subscriber_type = %{subscriber_type | balance: subscriber_type.balance + charge}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_call(subscriber, call_duration, date) do
    call = Call.new(call_duration, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end

  defimpl Subscriber, for: Telephony.Core.Postpaid do
    def print_invoice(_postpaid, calls, year, month) do
      calls =
        Enum.reduce(calls, [], fn call, acc ->
          if call.date.year == year and call.date.month == month do
            call_cost = call.call_duration * 1.04
            call = %{date: call.date, call_duration: call.call_duration, call_cost: call_cost}

            acc ++ [call]
          else
            acc
          end
        end)

      amount_due = Enum.reduce(calls, 0, &(&1.call_cost + &2))

      %{
        amount_due: amount_due,
        calls: calls
      }
    end
  end
end
