defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct full_name: nil, phone_number: nil, subscriber_type: :prepaid, calls: []

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(%{subscriber_type: subscriber_type} = subscriber, call_duration, date)
      when subscriber_type.__struct__ == Postpaid do
    Postpaid.make_call(subscriber, call_duration, date)
  end

  def make_call(%{subscriber_type: subscriber_type} = subscriber, call_duration, date)
      when subscriber_type.__struct__ == Prepaid do
    Prepaid.make_call(subscriber, call_duration, date)
  end

  def recharge(%{subscriber_type: subscriber_type} = subscriber, amount, date)
      when subscriber_type.__struct__ == Prepaid do
    Prepaid.recharge(subscriber, amount, date)
  end

  def recharge(_, _, _) do
    {:error, "Recharges can only be applied to prepaid accounts"}
  end
end
