defmodule Discuss.IdenticonTest do
  use ExUnit.Case, async: true
  alias Discuss.Identicon

  test "A binary is transformed into a corresponding identicon" do
    path = Application.get_env(:discuss, :path_to_identicon)
    assert Identicon.create_identicon("binary") == "#{path}/binary.png"
    assert File.read!("#{path}/binary.png") == File.read!(
             "#{System.get_env("DISCUSS_PROJECT_DIRECTORY")}/test/discuss/binary.png"
           )
  end
end
