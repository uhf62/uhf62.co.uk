#!/usr/bin/env bash

set -e

# 1. Find all Markdown files, excluding those in the vendor directory which is created in Travis.
# 2. Output content of those files.
# 3. Remove metadata lines which start with image:, image-credit-name:, etc.
# 4. Remove code blocks indented with four spaces.
# 5. Remove Jekyll commands ({% … %}).
# 6. Remove Markdown links.
# 7. Remove code blocks surrounded by ```.
# 8. Remove inline code marked up with ticks.
# 9. Finally, check spelling of everything that remains.

# shellcheck disable=SC2016
misspelled_words=$(find . -iname "*.markdown" -not -path "./vendor/*" -print0 \
  | xargs -0 cat \
  | grep -v -E "^(\s|\-)*(image|image-credit-name|image-credit-url|url):" \
  | grep -v -E "^\s{4}" \
  | sed "s/{%.*%}//" \
  | sed "s/](.*)/]/" \
  | sed -n '/^```/,/^```/ !p' \
  | sed 's/`.*`//' \
  | aspell --lang=en --encoding=utf-8 --personal=./.aspell.en.pws list)

if [[ "$misspelled_words" ]];
then
  echo "Misspelled words:"
  echo "$misspelled_words"
  exit 1
fi
