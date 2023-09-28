defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.Call
  alias Telephony.Core.Recharge

  defstruct credits: 0, recharges: []

  defimpl Subscriber, for: Telephony.Core.Prepaid do
    @price_per_minute 1.45

    def make_call(subscriber_type, call_duration, date) do
      if has_sufficient_credits?(subscriber_type, call_duration) do
        subscriber_type
        |> update_credits(call_duration)
        |> add_new_call(call_duration, date)
      else
        {:error, "Subscriber does not have sufficient credits"}
      end
    end

    def recharge(subscriber_type, amount, date) do
      recharge = Recharge.new(amount, date)

      %{
        subscriber_type
        | recharges: subscriber_type.recharges ++ [recharge],
          credits: subscriber_type.credits + amount
      }
    end

    defp update_credits(subscriber_type, call_duration) do
      credit_spent = @price_per_minute * call_duration
      %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    end

    defp add_new_call(subscriber_type, call_duration, date) do
      call = Call.new(call_duration, date)
      {subscriber_type, call}
    end

    defp has_sufficient_credits?(subscriber_type, call_duration) do
      subscriber_type.credits >= @price_per_minute * call_duration
    end

    def print_invoice(%{recharges: recharges} = subscriber_type, calls, year, month) do
      recharges = Enum.filter(recharges, &(&1.date.year == year && &1.date.month == month))

      calls =
        Enum.reduce(calls, [], fn call, acc ->
          if call.date.year == year && call.date.month == month do
            call_cost = call.call_duration * @price_per_minute
            call = %{date: call.date, call_duration: call.call_duration, call_cost: call_cost}

            acc ++ [call]
          else
            acc
          end
        end)

      %{
        credits: subscriber_type.credits,
        recharges: recharges,
        calls: calls
      }
    end
  end
end
