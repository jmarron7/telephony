defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.Call
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge

  setup do
    prepaid_subscriber = %Prepaid{credits: 10, recharges: []}

    prepaid_without_credits = %Prepaid{credits: 0, recharges: []}

    %{prepaid_subscriber: prepaid_subscriber, prepaid_without_credits: prepaid_without_credits}
  end

  test "make a call", %{prepaid_subscriber: prepaid_subscriber} do
    call_duration = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(prepaid_subscriber, call_duration, date)

    expected =
      {%Prepaid{credits: 7.1, recharges: []},
       %Call{
         call_duration: 2,
         date: date
       }}

    assert expected == result
  end

  test "make a call with insufficient credits", %{
    prepaid_without_credits: prepaid_without_credits
  } do
    call_duration = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(prepaid_without_credits, call_duration, date)

    expected = {:error, "Subscriber does not have sufficient credits"}

    assert expected == result
  end

  test "perform a recharge", %{prepaid_subscriber: prepaid_subscriber} do
    amount = 100
    date = NaiveDateTime.utc_now()

    result = Subscriber.recharge(prepaid_subscriber, amount, date)

    expected = %Prepaid{
      credits: 110,
      recharges: [
        %Recharge{
          amount: 100,
          date: date
        }
      ]
    }

    assert expected == result
  end

  test "print invoice" do
    date = ~D[2023-07-06]
    prev_month = ~D[2023-06-09]

    subscriber = %Telephony.Core.Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{
        credits: 253.6,
        recharges: [
          %Recharge{
            amount: 100,
            date: date
          },
          %Recharge{
            amount: 100,
            date: prev_month
          },
          %Recharge{
            amount: 100,
            date: prev_month
          }
        ]
      },
      calls: [
        %Call{
          call_duration: 2,
          date: date
        },
        %Call{
          call_duration: 10,
          date: prev_month
        },
        %Call{
          call_duration: 20,
          date: prev_month
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    assert Subscriber.print_invoice(subscriber_type, calls, 2023, 06) == %{
             credits: 253.6,
             calls: [
               %{
                 call_duration: 10,
                 call_cost: 14.5,
                 date: prev_month
               },
               %{
                 call_duration: 20,
                 call_cost: 29.0,
                 date: prev_month
               }
             ],
             recharges: [
               %Recharge{
                 amount: 100,
                 date: prev_month
               },
               %Recharge{
                 amount: 100,
                 date: prev_month
               }
             ]
           }
  end
end
