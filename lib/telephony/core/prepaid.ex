defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.Call
  alias Telephony.Core.Recharge

  defstruct credits: 0, recharges: []

  @price_per_minute 1.45

  def make_call(%{subscriber_type: subscriber_type} = subscriber, time_spent, date) do
    if has_sufficient_credits?(subscriber_type, time_spent) do
      subscriber
      |> update_credits(time_spent)
      |> add_new_call(time_spent, date)
    else
      {:error, "Subscriber does not have sufficient credits"}
    end
  end

  def recharge(%{subscriber_type: subscriber_type} = subscriber, amount, date) do
    recharge = Recharge.new(amount, date)

    subscriber_type = %{
      subscriber_type
      | recharges: subscriber_type.recharges ++ [recharge],
        credits: subscriber_type.credits + amount
    }

    %{subscriber | subscriber_type: subscriber_type}
  end

  defp update_credits(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    credit_spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end

  defp has_sufficient_credits?(subscriber_type, time_spent) do
    subscriber_type.credits >= @price_per_minute * time_spent
  end
end
