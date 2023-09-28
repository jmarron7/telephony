defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge
  alias Telephony.Core.Subscriber

  setup do
    postpaid_subscriber = %Subscriber{
      full_name: "Jane Doe",
      phone_number: "0000000000",
      type: %Postpaid{balance: 0}
    }

    prepaid_subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{credits: 10, recharges: []}
    }

    %{postpaid_subscriber: postpaid_subscriber, prepaid_subscriber: prepaid_subscriber}
  end

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: :prepaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert expected == result
  end

  test "create a postpaid subscriber" do
    # Given
    payload = %{
      full_name: "Jane Doe",
      phone_number: "1234567890",
      type: :postpaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expected = %Subscriber{
      full_name: "Jane Doe",
      phone_number: "1234567890",
      type: %Postpaid{balance: 0}
    }

    assert expected == result
  end

  test "make a postpaid call" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Postpaid{balance: 0}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.make_call(subscriber, 2, date) == %Subscriber{
             full_name: "John Doe",
             phone_number: "1234567890",
             type: %Postpaid{balance: 2.08},
             calls: [%Call{call_duration: 2, date: date}]
           }
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.make_call(subscriber, 2, date) == %Subscriber{
             full_name: "John Doe",
             phone_number: "1234567890",
             type: %Prepaid{credits: 7.1, recharges: []},
             calls: [%Call{call_duration: 2, date: date}]
           }
  end

  test "make a prepaid call without credits" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{credits: 0, recharges: []}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.make_call(subscriber, 2, date) ==
             {:error, "Subscriber does not have sufficient credits"}
  end

  test "perform a recharge on prepaid" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.recharge(subscriber, 100, date) == %Subscriber{
             full_name: "John Doe",
             phone_number: "1234567890",
             type: %Prepaid{credits: 110, recharges: [%Recharge{amount: 100, date: date}]},
             calls: []
           }
  end

  test "perform a recharge on postpaid" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Postpaid{balance: 0}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.recharge(subscriber, 100, date) ==
             {:error, "Recharges can only be applied to prepaid accounts"}
  end

  test "print a postpaid invoice" do
    date = ~D[2023-07-06]
    prev_month = ~D[2023-06-09]

    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Postpaid{balance: 0},
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
          call_duration: 35,
          date: prev_month
        }
      ]
    }

    expected = %{
      invoice: %{
        amount_due: 88.4,
        calls: [
          %{
            call_cost: 52.0,
            call_duration: 50,
            date: ~D[2023-06-09]
          },
          %{
            call_cost: 36.4,
            call_duration: 35,
            date: ~D[2023-06-09]
          }
        ]
      },
      subscriber: %Subscriber{
        calls: [
          %Call{
            call_duration: 10,
            date: ~D[2023-07-06]
          },
          %Call{
            call_duration: 50,
            date: ~D[2023-06-09]
          },
          %Call{
            call_duration: 35,
            date: ~D[2023-06-09]
          }
        ],
        full_name: "John Doe",
        phone_number: "1234567890",
        type: %Postpaid{balance: 0}
      }
    }

    assert Subscriber.print_invoice(subscriber, 2023, 06) == expected
  end

  test "print a prepaid invoice" do
    date = ~D[2023-07-06]
    prev_month = ~D[2023-06-09]

    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{
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

    assert Subscriber.print_invoice(subscriber, 2023, 06) ==
             %{
               invoice: %{
                 calls: [
                   %{call_cost: 14.5, call_duration: 10, date: ~D[2023-06-09]},
                   %{call_cost: 29.0, call_duration: 20, date: ~D[2023-06-09]}
                 ],
                 credits: 253.6,
                 recharges: [
                   %Recharge{amount: 100, date: ~D[2023-06-09]},
                   %Recharge{amount: 100, date: ~D[2023-06-09]}
                 ]
               },
               subscriber: %Subscriber{
                 full_name: "John Doe",
                 phone_number: "1234567890",
                 type: %Prepaid{
                   credits: 253.6,
                   recharges: [
                     %Recharge{amount: 100, date: ~D[2023-07-06]},
                     %Recharge{amount: 100, date: ~D[2023-06-09]},
                     %Recharge{amount: 100, date: ~D[2023-06-09]}
                   ]
                 },
                 calls: [
                   %Call{call_duration: 2, date: ~D[2023-07-06]},
                   %Call{call_duration: 10, date: ~D[2023-06-09]},
                   %Call{call_duration: 20, date: ~D[2023-06-09]}
                 ]
               }
             }
  end
end
