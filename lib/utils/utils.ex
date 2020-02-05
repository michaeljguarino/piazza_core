defmodule Piazza.Utils do
  def move_value(map, from, to) do
    case pop_in(map, from) do
      {nil, map} -> map
      {val, popped} -> put_in(popped, to, val)
    end
  end

  def copy_value(map, from, to) do
    case get_in(map, from) do
      nil -> map
      val -> put_in(map, to, val)
    end
  end
end