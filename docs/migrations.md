# Database Migrations
Database migrations are a scheme for updating database schema without having to rebuild the entire database.

Migrations are **.sql** files in the `back/sql` directory. Each numbered migration is applied to the database, in ascending numerical order, from the last migration which is found in the **migrations** table in the database.
