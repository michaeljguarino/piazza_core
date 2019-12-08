defmodule Envelope do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          keyed: String.t()
        }
  defstruct [:keyed]

  field :keyed, 1, type: :string
end
