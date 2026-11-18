# Instructions for agents

This repository builds a Lean 4 library on top of Tau Ceti and Mathlib. It
covers the subject of the plan that [README.md](README.md) links to: the plan
describes the subject, states its milestones, gives the sources, and may say
how the library should be built. Read the plan's pages for the work you do.

The milestones are results that the library must prove, and they measure how
much of the subject it covers. But the library is more than its milestones: it
is meant to be used, by later work here, by other projects, and eventually as
part of Tau Ceti or Mathlib. Write it so that moving it there needs little
more than a new namespace and copyright header.

`DESIGN.md`, once it exists, describes how the library is organized: its
folders and files, its core definitions and their API, and which parts build
on which. Follow it. If it is wrong or incomplete, propose a change to it
(see *Refactors* below) instead of working around it.

## Building

```sh
lake exe cache get      # Mathlib's compiled files; takes a minute
lake build --wfail
```

`--wfail` makes every warning an error, as CI does, so a `sorry` fails the
build. Before you push, `lake build --wfail` must succeed. The first build
compiles the Tau Ceti modules that the library imports, which can take some
minutes.

## Layout and names

- The library is under `Project/`, in the namespace `Project`. Its folders
  are Mathlib's top-level areas, such as `Project/Algebra/` or
  `Project/Geometry/`, and below them, topics. Use one file per topic. When
  `Foo.lean` gets a sibling `FooBar.lean`, make a folder instead:
  `Foo/Basic.lean` and `Foo/Bar.lean`.
- Name files and declarations after the mathematics, never after a milestone,
  an issue or a pull request. Follow Mathlib's naming conventions; a name
  never claims more than the statement (`_iff` only for an iff).
- A declaration about an existing Lean, Mathlib or Tau Ceti notion, one
  that dot notation on that type would find, goes in that type's namespace,
  such as `Matrix.trace_foo`, so that it can move upstream without a rename.
  Declarations about this library's own definitions go in `Project`.
- No file imports the whole library. `lake build` builds every file under
  `Project/` by itself (the `globs` in `lakefile.toml`), so a new file needs
  no import anywhere else. Do not add a file that imports the others.
- A new file has at most 1000 lines. No file may have more than 1500 (the
  build fails).

## Files

Every file is a module, and starts like this:

```lean
/-
Copyright (c) 2026 The FormalCommons contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The FormalCommons contributors
-/
module

public import Mathlib.LinearAlgebra.Matrix.Trace
public import Project.Algebra.Foo.Basic

/-!
# Title

What the file contains: its main definitions and results.

## References

* [A. Author, *Title of the book*][AuthorYear]
-/

public section

namespace Project

…

end Project

end
```

- The header is exactly as above; CI checks it. The module docstring comes
  right after the imports. Mathlib's style linters are on and fail the build,
  among them the limit of 100 characters per line.
- A module can import only modules, so every file starts with `module`.
  Import with `public import`, so that files that import yours see the
  declarations your statements use. Import the specific modules you need,
  never all of `Mathlib` or `TauCeti`, and never `Lean`, `Lake` or
  `Mathlib.Lean` modules. Specific `Mathlib.Tactic.*` modules are fine, but
  not `Mathlib.Tactic` itself.
- Only declarations in a `public section`, or marked `public`, are visible
  to other files. Other files see a definition's type, but not its body. Give
  a definition `foo` a lemma `foo_def` that states its body, proved by
  `(rfl)`, and unfold it with that lemma elsewhere. Use `@[expose]` only for a
  definition that other files must compute with, by `rfl` or `decide`.
- Cite sources in the module docstring's `## References`, with the key that
  the plan's `references.bib` gives the source.

## Rules for the source

- **No gaps.** No `sorry`, `admit`, new `axiom`, `native_decide` or
  `decide +native`. A theorem may depend only on `propext`,
  `Classical.choice` and `Quot.sound`. A `sorry` fails the build; reviewers
  check the axioms with `#print axioms`.
- **No `set_option`**, in any form, including `set_option maxHeartbeats … in`,
  and no `count_heartbeats`. Every declaration must check within Lean's
  default limits.
- **No metaprogramming**: no `meta`, `unsafe`, `elab`, `initialize`,
  `run_cmd`, `#eval`, attributes such as `@[tactic]` or `@[init]`, and no
  `macro` or `macro_rules` that is not `local` (`scoped` ones are ruled out
  too).

CI rejects these by reading the text of every file, comments included. So
keep the words `set_option`, `unsafe`, `native_decide`, `initialize`, `meta`,
`elab`, `macro` and `#eval` out of comments and names too, and do not start a
line of a comment with `axiom`.

## Writing a library

- **Use what exists.** Before you define or prove anything, search Mathlib
  (`.lake/packages/mathlib/Mathlib/`), Tau Ceti
  (`.lake/packages/TauCeti/TauCeti/`) and this library for it, by the
  statement and not only by the name, and use what you find. Never add a
  renamed copy, a wrapper, or a less general version of something that
  exists. Where the plan says that a result exists in a library, do not
  reprove it.
- **Definitions come with their API.** A new definition comes with the API
  that `DESIGN.md` lists for it, and at least what makes it usable: how to
  build and use it (`foo_def`, `mem_foo_iff`, constructors and eliminators),
  how it behaves under the operations around it, `@[simp]` on lemmas that
  put terms in normal form, and `@[ext]` for a structure. A new predicate
  comes with an example that satisfies it, or a use, in the same pull
  request.
- **State results in their natural generality.** Use the weakest hypotheses
  and typeclasses that make a statement true, as Mathlib would, but no
  generality that nothing needs. Drop hypotheses that the proof does not
  use.
- **Supporting results belong to the library.** A lemma that another proof
  could use is public, named after what it says, and placed with its topic,
  not in the file of the theorem that first needed it. Keep `private` for
  steps of one proof.
- **Milestones are theorems of the library.** A theorem that proves a
  milestone sits where its subject belongs. Its docstring ends with a line
  that names the milestone, such as "Milestone: *Bézout's theorem for plane
  curves*." That line is the only place a docstring mentions the plan. It has
  the plan's hypotheses and conclusion, in the plan's generality or more. If
  the library proves a more general result, the milestone is that result, or
  a corollary of it in the plan's form. If the plan's statement is wrong, see
  the next section.
- **Documentation.** Every definition and every main theorem has a docstring
  that says what it is, mathematically, not how it was proved or which issue
  it came from. Every file has a module docstring.
- **Proofs check quickly and read well.** Prefer an argument to a search, and
  automation (`simp`, `grind`, `omega`, `positivity`, `ring`) to long chains
  of rewrites. Split a proof of more than about 50 lines into lemmas.
- **Refactors.** Improving what exists, by sharing, moving, generalizing or
  renaming it, is welcome, but in a pull request of its own, for an issue of
  its own. If your work needs one, create an issue labelled `proposed` for it
  instead of doing it inside your pull request. A refactor updates every use
  in the same pull request and deletes the old name, with no deprecated
  alias, wrapper or forwarding file. If it changes how the library is
  organized, it updates `DESIGN.md` too.
- **Leave the setup alone.** Do not change `lakefile.toml`,
  `lake-manifest.json`, `lean-toolchain`, `LICENSE` or anything under
  `.github/`, unless the issue you work on asks for it and a person in the
  project opened it.
- **Keep pull requests focused.** One pull request does one issue, and adds
  at most 2000 lines. If an issue is too big for that, split it into smaller
  issues instead.

## Errors in the plan and its sources

The plan, and the sources it cites, can be wrong: a statement can be false or
miss a hypothesis, a proof can have a gap, a reference can point to the wrong
place. Expect this, and when you find one:

1. **Fix it as part of your work, if you can.** Prove the closest correct
   statement, by adding the missing hypothesis or correcting the conclusion,
   or close the gap in the proof. Keep the correction as small as the
   mathematics allows, and show that it is needed: a counterexample to the
   statement as given, or what exactly fails in the proof.
2. **Record it in `ERRATA.md`, in the same pull request.** Add an entry at the
   end of the section for the plan's page it concerns (start that section if
   there is none), in the form the file shows: where the error is, what is
   wrong and why, and what the library proves instead, naming the
   declarations. Say in the pull request's description that it corrects the
   plan.
3. **If the error is critical and you cannot fix it**, because the result is
   false and no correction keeps its point, or because every route you know
   fails, look for another route: another proof, from the plan's sources or
   elsewhere, or another formulation that serves the same purpose. Take it if
   you find one, and record the error and the route in `ERRATA.md`. If you
   find none, record the error in `ERRATA.md` as unresolved, with the routes
   you tried, in a pull request that is part of the issue but does not close
   it, and comment on the issue what you tried, so that the next agent tries
   something else.

Never weaken a milestone or change what it says without such an entry.

## Reviewing

Besides building, check each main theorem of the pull request with
`#print axioms`, in a scratch file that you do not commit:

```lean
import Project.Foo

#print axioms Project.foo_bar
```

Run it with `lake env lean Scratch.lean`. Then check that it is good library
code, by the rules above:

- Nothing in it repeats Mathlib, Tau Ceti or this library. Search for its
  main statements.
- Its statements are as general as they naturally are, its definitions come
  with their API, and its supporting lemmas are public and placed by topic.
- It fits `DESIGN.md`: the files, the definitions and the names it gives.
- A milestone's statement matches the plan. Where it does not, the pull
  request records the difference in `ERRATA.md`. Check that the error is
  real (the counterexample works, the gap is a gap), and that the
  correction is no bigger than it needs to be.

A pull request that adds or changes `DESIGN.md` is reviewed like code. Check
it against what the plan says about building the library, that every
milestone has a place in it, that each part is clear enough to become an
issue, and that the order of the parts can be built from what exists.

## Triage

An issue for a part of the library must agree with `DESIGN.md` and the plan.
If it does not, say where, and correct the issue or close it.
