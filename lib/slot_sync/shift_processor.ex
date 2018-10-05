defmodule SlotSync.Processor.Shift do
  @moduledoc """

  A GenServer that processes shift data.
  It compares incoming data to that in redis, and updates if changed.
  And then also publishes to Kafka.

  %{
    "account_id" => 77967,                                  x
    "acknowledged" => 1,                                    x
    "acknowledged_at" => "Mon, 01 Oct 2018 15:27:30 +0100", x
    "actionable" => false,
    "alerted" => false,
    "block_id" => 0,
    "break_time" => 0,                                      x
    "color" => "74a611",                                    x
    "created_at" => "Wed, 26 Sep 2018 12:24:58 +0100",      x
    "creator_id" => 5526232,                                x
    "end_time" => "Mon, 08 Oct 2018 00:15:00 +0100",
    "id" => 2076303948,                                     x
    "instances" => 0,                                       x
    "is_open" => false,                                     z
    "linked_users" => nil,
    "location_id" => 3999871,
    "notes" => "",                                          x
    "notified_at" => "Tue, 02 Oct 2018 22:32:58 +0100",     x
    "position_id" => 709909,                                x
    "published" => true,                                    x
    "published_date" => "Wed, 26 Sep 2018 16:59:05 +0100",  x
    "shiftchain_key" => "",
    "site_id" => 3530221,                                   x
    "start_time" => "Sun, 07 Oct 2018 21:00:00 +0100",      x
    "updated_at" => "Mon, 01 Oct 2018 15:27:30 +0100",      x
    "user_id" => 29205212                                   x
  }

  """
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def process(shift), do: GenServer.cast(__MODULE__, {:process, shift})

  # Callbacks

  @impl true
  def init(_) do
    {:ok, conn} = Redix.start_link("redis://localhost:6379/3", name: :redix)
    {:ok, conn}
  end

  @impl true
  def handle_cast({:process, shift}, conn) do
    if in_redis?(shift, conn) do
      # stats("processor.shift.matched")
    else
      # stats("processor.shift.unmatched")
      redis_set(shift, conn)
      publish(shift)
    end

    {:noreply, conn}
  end

  defp in_redis?(shift, conn) do
    md5(redis_get(shift, conn)) == md5(shift)
  end

  defp md5(data) do
    :crypto.hash(:md5, Poison.encode!(data))
    |> Base.encode16()
  end

  defp redis_get(shift, conn) do
    {:ok, shift} = Redix.command(conn, ["GET", shift["id"]])

    case shift do
      nil -> nil
      data -> Poison.decode!(data)
    end
  end

  defp redis_set(shift, conn) do
    {:ok, shift} = Redix.command(conn, ["SET", shift["id"], shift |> Poison.encode!()])
    shift
  end

  defp publish(shift), do: publisher().call(shift, shift["id"])
  defp publisher, do: SlotSync.Publishers.Kafka

  # defp stats(name), do: DogStatsd.increment(:datadogstatsd, name)
end
