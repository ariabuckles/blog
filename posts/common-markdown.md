Why Common Markdown isn't the Solution
========================================

[CommonMark][stmd]
(previously Common Markdown or Standard Markdown)
came out yesterday, promising to be a
single Markdown spec to rule them all. As I've been writing a
Markdown parser over the past few weeks, this was very exciting!
Finally I would know what to do about the various edge cases
not layed out in the [original Markdown syntax specification]
[mdsyntax]!

First off, CommonMark looks wonderful to write in. As a
content author, it looks like it would be much more preferable
to the current Markdown parser I'm using. For the vast
majority of cases, it looks like it does what I would mean
when I write something, making it very easy to work with as a
content author. The parser also looks like a nice implementation,
which is much less hacky than many I've seen. I think it's
wonderful that CommonMark is putting effort into making
the language better in these directions!

However, CommonMark states that one of its goals is
"to make Markdown easier to parse, and to eliminate the many
old inconsistencies and ambiguities that made writing a Markdown
parser so difficult."
I've been working on a Markdown parser for the past
few weeks, and in this respect CommonMark looks like it
is going to cause more problems than it solves.
CommonMark does a good job of making a lot of decisions
about edge cases, but it does so often by canonizing many
complex divergences from the original specification.
Ultimately, this makes [CommonMark Spec][spec] very long
and riddled with endless intricacies that will make working
with the language as a programmer more difficult.

*Note: I'm not going to talk about the standard issues around
naming and whether the spec is actually a spec. Other people
have covered those issue much better than I can hope to.*

[stmd]: http://standardmarkdown.com/
[mdsyntax]: http://daringfireball.net/projects/markdown/syntax
[spec]: http://jgm.github.io/stmd/spec.html


## Let's look at some of those intricacies:

### Paragraphs:

Here's what two paragraphs looks like:

    paragraph 1

    paragraph 2

Of course, if we put a line of text in between, they become one
paragraph, since they aren't separated by a blank line anymore:

    paragraph 1
    line of text
    paragraph 2

If we do the same thing but with `'%'` symbols, the same thing
happens:

    paragraph 1
    %%%
    paragraph 2

But if we replace the `'%'`s with `'*'`s, we get a horizontal rule:

    paragraph 1
    ***
    paragraph 2

Or if we replace the `'%'`s with `'-'`s, we get a heading.
Or if we use `'#'`s, we get paragraphs that are separated a bit more
than usual, because the middle line is a heading.

All of this means that it is not possible to write a simple rule for
when a paragraph (or other block element) ends. When a paragraph
ends is context dependent on what happens after that paragraph. And
while the rules are predictable for CommonMark, there are
still a lot of rules, which you need to know when you write a line
break. But moreover, anyone who adds an extension to the language
has the possibility of changing the semantics of paragraphs written in
CommonMark.

For example, if we added github-flavored table syntax, the following:

    a paragraph
    maybe | table
    -|-

changes semantically from a single block level element to two block
level elements. Consider if, instead, we required a paragraph to be
separated from the next block element by a blank line. Now, we don't
have to wonder when writing a `|` whether the dialect we are using
supports tables, and therefore whether writing `|` will add it to
the paragraph we are in or create a new element. But more importantly,
if we have a lot of content written in this Markdown dialect, and
we decide to support tables now, we don't have to worry as much about
whether we will accidentally transform someone's previously
innocuous text into something they did not intend.

(I'll admit that this example with tables is a little
contrived--`-|-` is unlikely to be used in content that one wouldn't
want to be a table. But it's a well known example of a problem that
can easily occur given the number of Markdown dialects available.)

### Links:

Links can look like
`[this](http://example.com)` or
`[this](<http://example.com>)` or
`[this][1]` or
`[this][]` or
`[this]` or
`<http://this>` or
`[this]((foo)and(bar))`.
But not `http://this.example.com`, because that would be silly.

That is too many link types!
Yes, several of them fix certain things that are difficult with
other link types (`'<'`).
But some of them are just convenient shorthand: `[this]` is
two characters shorter than `[this][]`, and means that
the resulting text formatting depends on whether a link
target for `[this]` exists *anywhere else in the document*.
The single level of parentheses nesting inside links, while
convenient for authoring content that may link to Wikipedia,
adds a lot of complexity to parsing. This isn't hard to
implement in a parser that fully tokenizes things at the
character level, but to add this to most of the existing
javascript parsers that match a whole link as a single
token, this would change the link regex from something like:

    /^\(([^\)]*)\)/

to something like:

    /^\(([^\(\)]*(?:\([^\(\)]*\)[^\(\)]*)*)\)/

Maybe this change is worth it to content creators. But given that
this often does not work in today's Markdown parsers, this,
and the several extensions like this, should not be part of the
core standard language.

### Inline HTML:

Of course, no Markdown spec is complete without allowing users
to inject arbitrary code into your website. While embedded HTML
makes sense for a static site generator, Markdown today is used
in many places where inline HTML is dangerous and shouldn't
be allowed. But instead of a html being an optional extension
(which would probably be supported only to various
degrees--several sites allow for embedding only a small subset
of HTML), we have an HTML grammar in the middle of our
Markdown specification. This rule alone means that many places
that would like to support Markdown will not be able to comply
with CommonMark--which would be fine if CommonMark
was a dialect, but unfortunate if CommonMark is considered
a standard.

## Why is Markdown everywhere?

All of these complexities come in the name of writing convenience.
That certainly seems like a reasonable goal--it would be wonderful if,
when you write something, your meaning is understood and conveyed into
the output correctly. That's the road CommonMark has taken, and
it's a reasonable road if you want to build a book-writing platform.

But Markdown didn't get where it is today by being the ideal format
to write longform text in (it certainly is a wonderful format to
write longform text in, and if you're looking for a dialect to do
exactly that, CommonMark looks like a very nice dialect to
work in). Markdown became so popular because it was simple and
somewhat extensible.

Not having a ton of different constructs
helped Markdown spread. Leaving room for extension helped
Markdown spread (while the implementations have left something to
be desired here, the original description was simple enough that
adding rules that didn't conflict is easy). Most popular sites that
use Markdown use their own variant of it. Github supports
`@`mentions and commit hash links; Reddit supports `^`superscripts.
But CommonMark takes us further away from both of those
attributes. If we need CommonMark + our own extension, the
most viable way to get that is by forking the CommonMark
parser. Writing another parser that complies with all the
CommonMark edge cases while adding functionality is a
huge undertaking, while writing a parser that complies with
most Markdown people actually use is not.

As [@stuartpb][stuartpb] said on [talk.standardmarkdown.com][],

> ...the goal of CommonMark should be to specify the smallest
agreed-upon subset of Markdown features coming from the original
implementation, and that means not introducing features or changing
semantics...

We could all use a specification of basic rules that a Markdown
parser should comply with. But it should be a small, core set
of rules that allows for simplicity of implementation and
simplicity of extension.

...And I found out yesterday that a version of this already exists!
[vfmd (*vanilla-flavoured Markdown*)][vfmd]
does this quite well. CommonMark is a wonderful implementation,
but vfmd is a better standard.

[stuartpb]: http://talk.standardmarkdown.com/users/stuartpb
[talk.standardmarkdown.com]: http://talk.standardmarkdown.com/t/what-changed-in-standard-markdown/15
[vfmd]: http://www.vfmd.org/

