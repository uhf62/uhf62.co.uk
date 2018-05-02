---
title: UHF 62
---

Software development using Python and Django by [Craig Anderson](http://craiga.id.au).

Company number 11112411.

### Values and Policies

Whilst being for-profit, UHF 62 is a progressive, socially and environmentally responsible company.

We aim to be open, accountable, and to get better.

We have a number of policies we're committed to.

<ul>
    {% for policy in site.policies %}
        <li><a href="{{ policy.url }}">{{ policy.title }}</a></li>
    {% endfor %}
</ul>
