defmodule Grandparent do
  @moduledoc false
  use Crucible.Type
  field(:id)
  field(:name)
  field(:age)
end

defmodule Parent do
  @moduledoc false
  use Crucible.Type
  field(:id)
  field(:name)
  field(:parent, relationship: Grandparent)
end

defmodule Child do
  @moduledoc false
  use Crucible.Type
  field(:id)
  field(:name)
  field(:parent_one, relationship: Parent)
  field(:parent_two, relationship: Parent)
end
