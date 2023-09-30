defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "John Doe",
        phone_number: "1234567890",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Jane Doe",
        phone_number: "0000000000",
        type: %Postpaid{balance: 0}
      }
    ]

    payload = %{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: :prepaid
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
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expected == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "New User",
      phone_number: "9999999999",
      type: :postpaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expected = [
      %Subscriber{
        full_name: "John Doe",
        phone_number: "1234567890",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Jane Doe",
        phone_number: "0000000000",
        type: %Postpaid{balance: 0}
      },
      %Subscriber{
        full_name: "New User",
        phone_number: "9999999999",
        type: %Postpaid{balance: 0}
      }
    ]

    assert expected == result
  end

  test "subscriber already exists", %{subscribers: subscribers, payload: payload} do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `1234567890` already exists"} == result
  end

  test "type does not exist", %{payload: payload} do
    payload = Map.put(payload, :type, :notreal)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are valid subscriber types"} == result
  end

  test "search for a subscriber", %{subscribers: subscribers} do
    expected = %Subscriber{
      full_name: "John Doe",
      phone_number: "1234567890",
      type: %Prepaid{credits: 0, recharges: []}
    }

    result = Core.search_subscriber(subscribers, "1234567890")
    assert expected == result
  end

  test "return nil when searching for a subscriber that does not exist", %{
    subscribers: subscribers
  } do
    result = Core.search_subscriber(subscribers, "123asdf4567890")

    assert nil == result
  end

  test "make a prepaid recharge", %{subscribers: subscribers} do
    date = NaiveDateTime.utc_now()

    expected = {
      [
        %Subscriber{
          full_name: "Jane Doe",
          phone_number: "0000000000",
          type: %Postpaid{balance: 0},
          calls: []
        },
        %Subscriber{
          calls: [],
          full_name: "John Doe",
          phone_number: "1234567890",
          type: %Prepaid{
            credits: 30,
            recharges: [
              %Recharge{
                amount: 30,
                date: date
              }
            ]
          }
        }
      ],
      %Subscriber{
        calls: [],
        full_name: "John Doe",
        phone_number: "1234567890",
        type: %Prepaid{
          credits: 30,
          recharges: [%Recharge{amount: 30, date: date}]
        }
      }
    }

    result = Core.recharge(subscribers, "1234567890", 30, date)

    assert result == expected
  end

  test "make a postpaid recharge", %{subscribers: subscribers} do
    date = NaiveDateTime.utc_now()
    result = Core.recharge(subscribers, "0000000000", 30, date)

    expected = {
      [
        %Subscriber{
          calls: [],
          full_name: "John Doe",
          phone_number: "1234567890",
          type: %Prepaid{
            credits: 0,
            recharges: []
          }
        }
      ],
      {:error, "Recharges can only be applied to prepaid accounts"}
    }

    assert result == expected
  end
end
