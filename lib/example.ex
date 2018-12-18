defmodule Example do
  use Crucible.DSL

  vpc :vpc_1 do
    tags = ["Shannon"]

    subnet :subnet_1 do
      tags = ["Apples"]
    end
  end
end
