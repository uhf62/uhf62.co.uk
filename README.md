# [UHF 62 website](https://www.uhf62.co.uk)

[![Build Status](https://www.travis-ci.org/uhf62/uhf62.co.uk.svg?branch=master)](https://www.travis-ci.org/uhf62/uhf62.co.uk)

Built using [Jekyll](https://jekyllrb.com) and [Bootstrap](https://getbootstrap.com). Hosted right here on [GitHub Pages](https://pages.github.com).

# Running Locally

To run locally:

    bundle install
    bundle exec jekyll serve

The site will be available at http://localhost:4000.

Requires [bundler](https://bundler.io).

# Preparing Images

Images compressed with [mozjpeg](https://github.com/mozilla/mozjpeg):

    cjpeg -outfile assets/slipnslide.optimised.jpg assets/slipnslide.jpg

# Preparing PDFs

Sometimes I like to produce PDFs from web content.

    pipenv install
    pipenv run weasyprint https\://www.uhf62.co.uk/policies/charitable_giving charity.pdf

Requires [Pipenv](https://pipenv.readthedocs.io/).

# Syntax Highlighting CSS

To generate syntax highlighting CSS, run the following command:

    bundle exec rougify style base16.solarized > _sass/rouge.scss
