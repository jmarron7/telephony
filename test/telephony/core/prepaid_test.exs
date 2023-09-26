defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.Call
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber

  setup do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, time_spent, date)

    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expected == result
  end
end
