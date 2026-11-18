# Errata

Errors found in the plan and in the sources it cites while formalizing them,
and what the library does about each. `AGENTS.md` says when to add an entry.

Add each entry at the end of the section for the plan's page that it
concerns, and start a section, `## <page>`, if there is none. Errors in a
source that no page of the plan covers go under `## Other sources`. Keeping
entries in their page's section keeps pull requests that add entries for
different pages from conflicting.

Each entry has this form:

```markdown
### <A short title>

- **Where:** the plan's page and milestone, or the source and its location.
- **Error:** what it says, and why that is wrong: a counterexample, or what
  fails in the proof.
- **Fix:** what the library proves instead, naming the declarations.
  For an unresolved error, **Unresolved:** the routes tried, and why each
  failed.
- **Pull request:** #<number>.
```
