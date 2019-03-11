---
title: Handling Integrity Errors in Django Migrations
description: "Short answer: don't 😉"
date: 2019-03-04 12:50:00 +0000
---

As part of a project I'm working on, I'm refactoring two nearly identical models (`create.Event` and `delete.Event`) into one (`generic.Event`).

Doing this requites a handful of migrations to:

 1. create the table for `generic.Event`;
 2. move the data from `create.Event` into `generic.Event` and delete the `create.Event` table; and
 3. move the data from `delete.Event` into `generic.Event` and delete the `delete.Event` table.

Migrations two and three call this function to move data between models:

```python
from django.forms.models import model_to_dict

def move_events(source_model, dest_model):
    for source in source_model.objects.all():
        source_fields = model_to_dict(source)
        del source_fields['id']

        dest = dest_model()
        for attr, value in source_fields.items():
            setattr(dest, attr, value)

        dest.save()
```

This works perfectly well … until I introduce real-world data and a unique `event_id` field into my models. 😢

```
django.db.utils.IntegrityError: duplicate key value violates unique constraint "generic_event_id_key"
DETAIL: Key (event_id)=(the-duplicate-key) already exists.
```

Taking [a Pythonic "easier to ask for forgiveness than permission" approach](https://docs.python.org/3/glossary.html#term-eafp), my first attempt at this was to wrap the call to save in a try … except block:

```python
try:
    dest.save()
except IntegrityError as err:
    print("Ignoring unhandled integrity error:")
    print(err)
```

I naively deployed this fix expecting my problems to vanish, but the exceptions persisted. 😭

I was now getting TransactionManagementErrors.

```
django.db.transaction.TransactionManagementError: An error occurred in the current transaction. You can't execute queries until the end of the 'atomic' block.
```

After some digging, reading, and thinking, I realised that the cause of the IntegrityError isn't Python—it's Postgres. Handling the error in Python is suppressing an error about a failed transaction, but the transaction is still failed.

[The Django docs give a clue about what's happening here](https://docs.djangoproject.com/en/2.1/topics/db/transactions/#handling-exceptions-within-postgresql-transactions):

> Inside a transaction, when a call to a PostgreSQL cursor raises an exception (typically `IntegrityError`), all subsequent SQL in the same transaction will fail with the error “current transaction is aborted, queries ignored until end of transaction block”. While simple use of `save()` is unlikely to raise an exception in PostgreSQL, there are more advanced usage patterns which might, such as saving objects with unique fields, saving using the force_insert/force_update flag, or invoking custom SQL.

In order to stop IntegrityErrors in your migrations, you need to "look before you leap" to stop the cause of them in the first place. For me, that meant something like the following:

```python
def move_events(source_model, dest_model):
    for source in source_model.objects.all():
        source_fields = model_to_dict(source)
        del source_fields['id']

        # Ignore records with pre-existing event IDs.
        event_id = source_fields['event_id']
        if dest_model.objects.filter(event_id=event_id).exists():
            print("Discarding record with duplicate event ID.")
            pprint(source_fields)
            continue

        dest = dest_model()
        for attr, value in source_fields.items():
            setattr(dest, attr, value)

        dest.save()
```
