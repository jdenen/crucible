defmodule Crucible.DSLTest do
  use ExUnit.Case
  import Helper

  setup do
    on_exit(fn -> Crucible.DSL.Store.clear() end)
  end

  test "dsl can support simple struct" do
    with_module do
      defmodule Stuff do
        use Crucible.DSL

        grandparent :gp1 do
          name = "George"
          age = 71
        end
      end
    end

    on_exit(fn -> unload_module(Stuff) end)

    assert [%Grandparent{id: :gp1, name: "George", age: 71}] == Stuff.process_infrastructure()
  end

  test "dsl can support nested structs" do
    with_module do
      defmodule Stuff do
        use Crucible.DSL

        grandparent :gp1 do
          name = "George"

          parent :p1 do
            name = "Sue"
          end
        end
      end
    end

    on_exit(fn -> unload_module(Stuff) end)

    actual = Stuff.process_infrastructure()

    assert %Grandparent{id: :gp1, name: "George"} in actual
    assert %Parent{id: :p1, parent: :gp1, name: "Sue"} in actual
  end

  test "dsl can support deeply nested calls" do
    with_module do
      defmodule Stuff do
        use Crucible.DSL

        grandparent :gp1 do
          name = "George"

          parent :p1 do
            name = "Orwell"

            child :c1 do
              name = "Chad"
            end
          end
        end
      end
    end

    on_exit(fn -> unload_module(Stuff) end)

    actual = Stuff.process_infrastructure()

    assert %Grandparent{id: :gp1, name: "George"} in actual
    assert %Parent{id: :p1, name: "Orwell", parent: :gp1} in actual
    assert %Child{id: :c1, name: "Chad"} in actual
  end

  test "child properties cannot affect parent properties" do
    with_module do
      defmodule Stuff do
        use Crucible.DSL

        grandparent :gp1 do
          age = 71

          parent :p1 do
            name = "Jeff"
          end
        end
      end
    end

    on_exit(fn -> unload_module(Stuff) end)

    actual = Stuff.process_infrastructure()

    assert %Grandparent{id: :gp1, age: 71} in actual
    assert %Parent{id: :p1, name: "Jeff", parent: :gp1} in actual
  end
end
