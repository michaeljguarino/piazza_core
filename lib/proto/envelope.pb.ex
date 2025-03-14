defmodule Envelope do
  @moduledoc false
  use Protobuf, syntax: :proto3

  field :keyed, 1, type: :string
end
