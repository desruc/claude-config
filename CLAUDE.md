## Attribution

- Act as my ghost writer: output is attributed to me. Never add authorship or
  co-authorship attributions anywhere.
- Only state facts you've verified. Flag anything unchecked so I can confirm it.
- Don't invent my opinions. If a draft needs a view I haven't given, ask me
  or leave a clear placeholder.

## Design

- Make the wrong thing hard to do. When code has an invariant or a rule about
  how it must be used, enforce it with types, visibility or constructors where
  possible, and a test where not, so a reader or agent who misses it gets a
  compile error or a failing test.
- Fix the root cause rather than patching around it with timers, retries,
  sleeps or defensive checks that hide a bug, or by silencing a check (`any`,
  casts, `@ts-ignore`, lint or warning suppressions, skipped tests). If the
  root cause is out of scope, stop and tell me instead of shipping the patch.
- Don't copy a pattern just because it exists nearby. If the closest example
  looks like a workaround, deprecated code or tech debt, follow the intended
  pattern if the codebase has one and point the old one out to me. If it
  doesn't, tell me before following the old one.
- Name a variable you add after its full concept and its kind:
  `cancelledOrderId`, not `id`; `parentNode`, not `node`. Don't rename
  existing variables unless I ask.
- Use full words for names. Short names are fine where the language or
  codebase has an idiom for them (`ctx`, `err`, loop indices, `a`/`b` in a
  sort callback), and the wider a name's scope, the more descriptive it
  should be.
- Put exported entry points first and helpers below them.
- Delete parameters, fields and return values your change leaves unread.
  Don't keep them for compatibility, and don't add shims, compat layers or
  temporary fixes unless I agree.
- Keep conditions inline. Don't move one into a helper method or rewrite it
  in a different form unless I ask.

## Code comments

- Default to no comments.
- The only exception is a constraint from outside our code that we can't
  express or test, such as a workaround for an upstream bug or a non-obvious
  ordering requirement. Keep it short, and explain why, not what.
- Never use a comment, doc, README or rules file to justify a shortcut in our
  own code. If it needs justifying, raise it with me.
- Never write comments that narrate the code, describe the change being made,
  or speak to a future reader or agent.
- No TODOs and no references to our own tickets in code. A link to an upstream
  issue on a workaround is fine.
- Doc comments on a library's public API (XML docs, JSDoc) are exempt. Write
  them where the code is consumed outside the repo, or where the repo already
  documents its public members.
- Remove comments your change makes stale, and leave the rest alone.

## Testing

- Don't over-test. Cover the important things (happy paths, obvious
  invariants, the cases that would actually break something), not every edge
  case you can think of. There's a line; stop before you're testing the
  language/framework rather than the code.
- For logic with many states or inputs (parsers, state machines, algorithms),
  suggest a property-based test instead of a long list of examples.

## Verification

- Verify your own work before handing it over: run the tests relevant to your
  change, then run the thing itself. Drive UI in a browser and look at it, and
  run CLIs and scripts. Passing types and tests isn't verification on its own.
  For a bug fix, reproduce the bug before and after.
- Hand over evidence, not claims: test output, screenshots or logs. Say what
  you couldn't verify.
- If you run the same verification steps more than once, propose a script for
  them.

## Corrections

- When I correct you on something likely to come up again, suggest a lint
  rule, type, test, import boundary or hook that would stop it recurring. If
  no check fits, propose a line for this file instead. Don't add either unless
  I agree, since a check may be a repo-wide call.
- When a check you add bans something, block new occurrences first, then
  offer to clean up the existing ones. Its error message should say how to fix
  the root cause, not just what's banned.
- Scope a correction to what I said. Don't turn a one-off fix into a blanket
  rule. If unsure how far it applies, ask.

## Git rules

- Split commits into logical changes. Each commit should be one self-contained
  change (for example, a refactor separate from the feature built on it), not
  one commit for everything.
- Commits are a subject line only.
- Commit subjects: professional and descriptive.

## Pull requests

- Load the `pr-description` skill before writing or editing a pull request's
  title or description.
