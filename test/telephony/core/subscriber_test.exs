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
      subscriber_type: %Postpaid{balance: 0}
    }

    prepaid_subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{postpaid_subscriber: postpaid_subscriber, prepaid_subscriber: prepaid_subscriber}
  end

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expected == result
  end

  test "create a postpaid subscriber" do
    # Given
    payload = %{
      full_name: "Jane Doe",
      phone_number: "1234567890",
      subscriber_type: :postpaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expected = %Subscriber{
      full_name: "Jane Doe",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{balance: 0}
    }

    assert expected == result
  end

  test "make a postpaid call", %{postpaid_subscriber: postpaid_subscriber} do
    date = NaiveDateTime.utc_now()

    expected = %Subscriber{
      full_name: "Jane Doe",
      phone_number: "0000000000",
      subscriber_type: %Postpaid{balance: 2.08},
      calls: [
        %Call{
          call_duration: 2,
          date: date
        }
      ]
    }

    result = Subscriber.make_call(postpaid_subscriber, 2, date)

    assert expected == result
  end

  test "make a prepaid call", %{prepaid_subscriber: prepaid_subscriber} do
    date = NaiveDateTime.utc_now()

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

    result = Subscriber.make_call(prepaid_subscriber, 2, date)

    assert expected == result
  end

  test "perform a recharge", %{prepaid_subscriber: prepaid_subscriber} do
    date = NaiveDateTime.utc_now()

    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{
        credits: 12,
        recharges: [
          %Recharge{
            amount: 2,
            date: date
          }
        ]
      },
      calls: []
    }

    result = Subscriber.recharge(prepaid_subscriber, 2, date)

    assert expected == result
  end

  test "throw error when recharging non-prepaid account", %{
    postpaid_subscriber: postpaid_subscriber
  } do
    date = NaiveDateTime.utc_now()

    expected = {:error, "Recharges can only be applied to prepaid accounts"}

    result = Subscriber.recharge(postpaid_subscriber, 2, date)

    assert expected == result
  end
end
