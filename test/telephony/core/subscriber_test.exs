defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
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

  test "make a postpaid call" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Postpaid{balance: 0}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.make_call(subscriber, 2, date) == %Subscriber{
             full_name: "John Doe",
             phone_number: "1234567890",
             subscriber_type: %Postpaid{balance: 2.08},
             calls: [%Call{call_duration: 2, date: date}]
           }
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.make_call(subscriber, 2, date) == %Subscriber{
             full_name: "John Doe",
             phone_number: "1234567890",
             subscriber_type: %Prepaid{credits: 7.1, recharges: []},
             calls: [%Call{call_duration: 2, date: date}]
           }
  end

  test "make a prepaid call without credits" do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    date = NaiveDateTime.utc_now()

    assert Subscriber.make_call(subscriber, 2, date) ==
             {:error, "Subscriber does not have sufficient credits"}
  end
end
