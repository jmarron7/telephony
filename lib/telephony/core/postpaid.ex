defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.Call

  defstruct balance: 0

  @price_per_minute 1.04

  def make_call(%{subscriber_type: subscriber_type} = subscriber, call_duration, date) do
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
end
