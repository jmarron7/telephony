defmodule Telephony.Core.Call do
  defstruct call_duration: nil, date: nil

  def new(call_duration, date) do
    %__MODULE__{call_duration: call_duration, date: date}
  end
end
