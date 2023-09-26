defmodule Subscriber.Subscriber do
  use ExUnit.Case
  alias Subscriber.Subscriber

  test "create a new subscriber" do
    # Given
    payload = %{
      full_name: "John Doe",
      id: "123",
      phone_number: "1234567890"
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expected = %Subscriber{
      full_name: "John Doe",
      id: "123",
      phone_number: "1234567890"
    }

    assert expected == result
  end
end
