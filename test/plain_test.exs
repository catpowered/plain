defmodule PlainTest do
  use ExUnit.Case
  doctest Plain

  test "greets the world" do
    assert Plain.hello() == :world
  end
end
