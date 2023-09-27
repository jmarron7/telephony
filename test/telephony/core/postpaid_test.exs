defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.Call
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Subscriber

  setup do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{balance: 0},
      calls: []
    }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    call_duration = 2
    date = NaiveDateTime.utc_now()
    result = Postpaid.make_call(subscriber, call_duration, date)

    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{balance: 2.08},
      calls: [
        %Call{
          call_duration: 2,
          date: date
        }
      ]
    }

    assert expected == result
  end
end
