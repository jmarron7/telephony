defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.Call
  alias Telephony.Core.Invoice
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

  test "print invoice" do
    date = ~D[2023-07-06]
    prev_month = ~D[2023-06-09]

    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{balance: 90 * 1.04},
      calls: [
        %Call{
          call_duration: 10,
          date: date
        },
        %Call{
          call_duration: 50,
          date: prev_month
        },
        %Call{
          call_duration: 30,
          date: prev_month
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    expected = %{
      amount_due: 80 * 1.04,
      calls: [
        %{
          call_duration: 50,
          call_cost: 50 * 1.04,
          date: prev_month
        },
        %{
          call_duration: 30,
          call_cost: 30 * 1.04,
          date: prev_month
        }
      ]
    }

    assert expected == Invoice.print(subscriber_type, calls, 2023, 06)
  end
end
