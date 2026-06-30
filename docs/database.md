# Database Compatibility

This page covers ODBC driver requirements and host-native MariaDB setup. It is only relevant if you are running MariaDB outside Docker (e.g. host-native install or debugging type conversions). If you use the Docker workflow described in [dev.md](dev.md), you can skip this page.

## Host-Native MariaDB Setup (Reference)

Install MariaDB and set your database root user password:

```bash
sudo apt install mariadb-server
sudo mysql_secure_installation
```

Create the database `dyalog_cms`, create user `dcms` and grant privileges. Generate a secure password — it should also be set in `secrets/secrets.json5`.

```bash
sudo mariadb -u root -p
create database dyalog_cms;
create user dcms identified by 'YOUR_MARIADB_PASSWORD';
grant all privileges on dyalog_cms.* to dcms;
```

### ODBC Driver Requirements

> [!WARNING]
> You must use the [MySQL ODBC Driver](https://dev.mysql.com/downloads/connector/odbc/), as the type conversions in `sql/type_conversions.csv` and consequently `#.DCMS.GLOBAL.type_conversions` and `#.DCMS.GLOBAL.type_sqapl` (set in `#.DCMS.SQL.ProcessTableInformation`) rely on the numbers in the `DATA_TYPE` column of `#.(SQA.Columns DCMS.SQL.db)`.

> [!CAUTION]
> If a type which has no conversion defined in `sql/type_conversions.csv` is present in the database, setup fails with error 106 "Unknown column type in rows: ", listing the row numbers in `1↓2⊃#.SQA.Columns #.DCMS.SQL.db` (`d` in ProcessTableInformation) with the problem data types.

If you use a different driver, check the output of `#.SQA.Columns #.DCMS.SQL.db` and change the numeric values in the 3rd column of `sql/type_conversions.csv`.

You can find out which `DATA_TYPE` numbers should be used with:

```APL
      ]view 2(↑⍤1)2⊃#.SQA.TypeInfo #.DCMS.SQL.db
```

and relating the `TYPE_NAME` column to those specified in `sql/type_conversions.csv`.

To see only types used in the database, try:

```APL
      {∪1↓⍵[;(1⌷⍵)⍳⊆'DATA_TYPE' 'TYPE_NAME']}2⊃#.SQA.Columns db
```