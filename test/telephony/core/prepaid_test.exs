defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.Call
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge
  alias Telephony.Core.Subscriber

  setup do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    subscriber_without_credits = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: subscriber, subscriber_without_credits: subscriber_without_credits}
  end

  test "make a call", %{subscriber: subscriber} do
    call_duration = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, call_duration, date)

    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          call_duration: 2,
          date: date
        }
      ]
    }

    assert expected == result
  end

  test "make a call with insufficient credits", %{subscriber_without_credits: subscriber} do
    call_duration = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, call_duration, date)

    expected = {:error, "Subscriber does not have sufficient credits"}

    assert expected == result
  end

  test "perform a recharge", %{subscriber: subscriber} do
    amount = 100
    date = NaiveDateTime.utc_now()

    result = Prepaid.recharge(subscriber, amount, date)

    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [
          %Recharge{
            amount: 100,
            date: date
          }
        ]
      },
      calls: []
    }

    assert expected == result
  end
end
