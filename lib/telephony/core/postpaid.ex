defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.Call

  defstruct balance: 0

  defimpl Subscriber, for: Telephony.Core.Postpaid do
    @price_per_minute 1.04

    def recharge(_, _, _) do
      {:error, "Recharges can only be applied to prepaid accounts"}
    end

    def print_invoice(_postpaid, calls, year, month) do
      calls = Enum.reduce(calls, [], &filter_calls(&1, &2, year, month))

      amount_due = Enum.reduce(calls, 0, &(&1.call_cost + &2))

      %{
        amount_due: amount_due,
        calls: calls
      }
    end

    def make_call(type, call_duration, date) do
      type
      |> update_balance(call_duration)
      |> add_call(call_duration, date)
    end

    defp filter_calls(call, acc, year, month) do
      if call.date.year == year and call.date.month == month do
        call_cost = call.call_duration * 1.04
        call = %{date: call.date, call_duration: call.call_duration, call_cost: call_cost}

        acc ++ [call]
      else
        acc
      end
    end

    defp update_balance(type, call_duration) do
      charge = call_duration * @price_per_minute
      %{type | balance: type.balance + charge}
    end

    defp add_call(type, call_duration, date) do
      call = Call.new(call_duration, date)
      {type, call}
    end
  end
end
