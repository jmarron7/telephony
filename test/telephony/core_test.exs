defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "John Doe",
        phone_number: "1234567890",
        subscriber_type: :prepaid
      }
    ]

    payload = %{
      full_name: "John Doe",
      phone_number: "1234567890",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []
    result = Core.create_subscriber(subscribers, payload)

    expected = [
      %Subscriber{
        full_name: "John Doe",
        phone_number: "1234567890",
        subscriber_type: :prepaid
      }
    ]

    assert expected == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Jane Doe",
      phone_number: "0000000000",
      subscriber_type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expected = [
      %Subscriber{
        full_name: "John Doe",
        phone_number: "1234567890",
        subscriber_type: :prepaid
      },
      %Subscriber{
        full_name: "Jane Doe",
        phone_number: "0000000000",
        subscriber_type: :prepaid
      }
    ]

    assert expected == result
  end

  test "subscriber already exists", %{subscribers: subscribers, payload: payload} do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `1234567890` already exists"} == result
  end

  test "subscriber_type does not exist", %{payload: payload} do
    payload = Map.put(payload, :subscriber_type, :notreal)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are valid subscriber types"} == result
  end
end
