defmodule Piazza.PubSub.BroadcasterTest do
  use ExUnit.Case

  describe "#notify/1" do
    test "It will notify all consumers" do
      {:ok, _} = Piazza.TestBroadcaster.start_link(:ok)
      {:ok, _} = Piazza.EchoConsumer.start_link(:ok)
      event = %Piazza.TestEvent{item: :hello}
      Piazza.TestBroadcaster.notify(event)

      assert_receive {:event, %Piazza.TestEvent{item: :hello}}
    end
  end
end