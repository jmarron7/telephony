defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.Call
  alias Telephony.Core.Postpaid

  setup do
    %{postpaid_subscriber: %Postpaid{balance: 0}}
  end

  test "make a call", %{postpaid_subscriber: postpaid_subscriber} do
    call_duration = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(postpaid_subscriber, call_duration, date)

    expected = {
      %Postpaid{
        balance: 2.08
      },
      %Call{
        call_duration: 2,
        date: date
      }
    }

    assert expected == result
  end

  test "attempt a recharge" do
    postpaid_subscriber = %Postpaid{balance: 0}

    assert {:error, "Recharges can only be applied to prepaid accounts"} ==
             Subscriber.recharge(postpaid_subscriber, 100, NaiveDateTime.utc_now())
  end

  test "print invoice" do
    date = ~D[2023-07-06]
    prev_month = ~D[2023-06-09]

    postpaid_subscriber = %Postpaid{balance: 90 * 1.04}

    calls = [
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

    assert expected == Subscriber.print_invoice(postpaid_subscriber, calls, 2023, 06)
  end
end
