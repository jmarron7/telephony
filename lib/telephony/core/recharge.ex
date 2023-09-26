defmodule Telephony.Core.Recharge do
  defstruct amount: nil, date: nil

  def new(amount, date \\ NaiveDateTime.utc_now()) do
    %__MODULE__{amount: amount, date: date}
  end
end
