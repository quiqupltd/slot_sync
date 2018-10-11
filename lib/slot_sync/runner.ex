defmodule SlotSync.Runner do
  @moduledoc """
  Ensures sync peroid covers a rolling amount of data on each call
  """

  use Confex, otp_app: :slot_sync

  @spec start() :: :ok
  def start do
    now = Timex.now()
    state_data = Timex.shift(now, days: -1) |> DateTime.to_iso8601()
    end_date = Timex.shift(now, days: 1) |> DateTime.to_iso8601()
    # state_data = Timex.shift(now, days: days()) |> DateTime.to_iso8601()
    # end_date = Timex.shift(now, days: days()) |> DateTime.to_iso8601()

    SlotSync.WIW.shifts(state_data, end_date)

    :ok
  end

  # defp days(), do: config()[:days]
end
