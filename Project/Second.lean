module

public import Project.Basic

/-!
# A second example

Checks that a module under `Project/` that nothing imports is built, and that it can unfold an
exposed definition of another module.
-/

public section

namespace Project

/-- `double 1` is `2`. -/
theorem double_one : double 1 = 2 := rfl

end Project

end
