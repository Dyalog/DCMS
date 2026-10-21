# DCMS Writing Style

Follow this guide when writing documentation for DCMS, including Markdown files, `CLAUDE.md`, and OpenAPI `description:` strings. To review a change against it, run `/drev`.

## Readers

Write for the reader of the file you are editing:

- `README.md`: developers building a frontend against the API.
- `CONTRIBUTING.md` and `docs/`: people working on DCMS itself.
- `CLAUDE.md`: an LLM working on DCMS.

## Prose

### Use Literal Verbs

Choose the verb for what actually happened. A change is merged, released, deployed or fixed, not "landed". A value is stored in a file; it doesn't "live" there. Avoid "surfaces", "ships", "bites", "owns" and "sits" in the same way.

### Say Who Acts

Documents, environments and changes don't act. Instead of "production turns logging off", write "logging is off in production". Instead of "new state must justify itself", write "justify any new state you add". When the actor is the reader, give an instruction.

Code may be the subject when it really performs the action:

> `HandleError` converts the error to an HTTP response.

### Name What You Mean

Prefer naming what you mean to pointing back at it with "it", "this", "those" or "ones". Write "every error suspends, including expected errors", not "every error suspends, including the deliberately signalled ones". A pronoun is fine when the thing it refers to is in the same sentence and can't be mistaken.

### Vary the Structure

Vary the grammatical structure and framing of your sentences. Prose in which every sentence has the same shape is tiring to read, even when each sentence is correct on its own.

### Write Rules as Instructions

In a guide, write each rule in the imperative: "Name modules in uppercase", not "Modules are UPPERCASE". To avoid a run of rules that all open the same way, you may occasionally state one as a description instead. Elsewhere, address the reader as "you" only where it helps.

### Write Full Sentences

Prefer a full sentence to a slogan ("Call down, signal up.") or a fragment ("How DCMS APL code is written."). You may use a slogan in very rare cases: where it is clearer than the full sentence, or where it deliberately emphasises a principle the reader must remember. Follow it with the full statement. Short clauses joined by semicolons read as slogans too. Write "every error is trapped and returned to the client as an HTTP response", not "nothing suspends; every error becomes a response".

### Say It Once

Make each point once. If a sentence repeats what the paragraph has already said, cut it or replace it with something the reader doesn't know yet.

### Use Emphasis Sparingly

Bold a term where you define it, or a warning the reader must not miss. Use a bold lead-in on a bullet, or a colon that stages a reveal ("The exception is: …"), only rarely.

Use a GitHub callout (`> [!WARNING]`) only for a hazard or limit the reader must not miss, such as a required driver.

Use at most one em-dash in five paragraphs. A comma, colon, brackets or a new sentence usually does the job.

## Language

Use British spelling: behaviour, normalise, serialisation. Spell an identifier as it is in the code, such as `responses.unauthorized`. Write "start-up" with a hyphen. Don't hyphenate an adverb ending in "-ly": write "deliberately signalled", not "deliberately-signalled". As in the Dyalog documentation, write "Ride" for the development environment and `RIDE_INIT` for the configuration parameter.

## Markdown

- Write headings in Title Case, with articles, conjunctions and prepositions in lowercase: "Calling the API", "Run Locally with Dummy Data". Go no deeper than `###`.
- Don't wrap lines. Write each paragraph or list item on one line.
- Link to source files with plain links, not bold ones.
- Put identifiers, file paths, status codes and config keys in inline code.
- Label each code block with its language, `apl` or `sh`, on the opening fence, and don't indent its lines with the six-space prompt. If a code block shows a session, with input at the six-space prompt and the result below it, leave it unlabelled so that the output isn't highlighted as code.

  ```
        2×⍳3
  2 4 6
  ```
- Mark italics with underscores: `_path parameter_`.
