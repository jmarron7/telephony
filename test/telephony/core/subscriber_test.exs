defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber

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
      subscriber_type: %Postpaid{spent: 0}
    }

    assert expected == result
  end
end
