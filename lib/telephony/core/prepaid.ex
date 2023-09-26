defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.Call

  defstruct credits: 0, recharges: []
  @price_per_minute 1.45

  def make_call(%{subscriber_type: subscriber_type} = subcriber, time_spent, date) do
    credit_spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    subscriber = %{subcriber | subscriber_type: subscriber_type}
    call = Call.new(time_spent, date)
    %{subscriber | calls: subcriber.calls ++ [call]}
  end
end
