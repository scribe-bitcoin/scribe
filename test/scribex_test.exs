defmodule ScribexTest do
  use ExUnit.Case
  doctest Scribex

  test "greets the world" do
    assert Scribex.hello() == :world
  end
end
