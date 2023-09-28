defprotocol Subscriber do
  @fallback_to_any true

  def print_invoice(type, calls, year, month)
  def make_call(type, call_duration, date)
  def recharge(type, amount, date)
end

defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct full_name: nil, phone_number: nil, type: :prepaid, calls: []

  def new(%{type: :prepaid} = payload) do
    payload = %{payload | type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{type: :postpaid} = payload) do
    payload = %{payload | type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(subscriber, call_duration, date) do
    case Subscriber.make_call(subscriber.type, call_duration, date) do
      {:error, message} -> {:error, message}
      {type, call} -> %{subscriber | type: type, calls: subscriber.calls ++ [call]}
    end
  end

  def recharge(subscriber, amount, date) do
    case Subscriber.recharge(subscriber.type, amount, date) do
      {:error, message} -> {:error, message}
      type -> %{subscriber | type: type}
    end
  end

  def print_invoice(subscriber, year, month) do
    invoice = Subscriber.print_invoice(subscriber.type, subscriber.calls, year, month)

    %{subscriber: subscriber, invoice: invoice}
  end
end
