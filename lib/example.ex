defmodule Example do
  use Crucible.DSL

  vpc :vpc_1 do
    tags = ["Shannon"]

    subnet :subnet_1 do
      tags = ["Apples"]
    end
  end

  subnet :subnet_2 do
    vpc = :vpc_1
    tags = ["Jenkins"]
  end
end
