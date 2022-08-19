# Database Migrations
Database migrations are a scheme for updating database schema without having to rebuild the entire database.

Migrations are **.sql** files in the `src/sql` directory. Each numbered migration is applied to the database, in ascending numerical order, from the last migration which is found in the **migrations** table in the database.

Migrations have a file name of the type `0-description.sql`. The migrations table itself is defined in `migrations.sql`.