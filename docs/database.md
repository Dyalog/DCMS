# Database Compatibility
## Install ODBC drivers on the host system
> **WARNING**  
	You **MUST** use the [**MySQL ODBC Driver**](https://dev.mysql.com/downloads/connector/odbc/), as the type conversions in `src/sql/type_conversions.csv` and consequently `#.GLOBAL.type_conversions` and `#.GLOBAL.type_sqapl` (set in `#.DCMS.SQL.ProcessTableInformation`) rely on the numbers in the `DATA_TYPE` column of `#.(SQA.Columns DCMS.SQL.db)`.

> **FAILURE**  
	If a type which has no conversion defined in `src/sql/type_conversions.csv` is present in the database, setup will fail with an error 106 "Uknown column type in rows: ", listing the row numbers in `1↓2⊃#.SQA.Columns #.DCMS.SQL.db` (`d` in ProcessTableInformation) with the problem data types.

If you use a different driver, check the output of `#.SQA.Columns #.DCMS.SQL.db` and change the numeric values in the 3rd column of `src/sql/type_conversions.csv`.

You can find out which `DATA_TYPE` numbers should be used with:

```APL
      ]view 2(↑⍤1)2⊃#.SQA.TypeInfo #.DCMS.SQL.db
```

and relating the `TYPE_NAME` column to those specified in `src/sql/type_conversions.csv`.

To see only types used in the database, try:

```APL
      {∪1↓⍵[;(1⌷⍵)⍳⊆'DATA_TYPE' 'TYPE_NAME']}2⊃#.SQA.Columns db
```

## Host-native MariaDB setup (reference)

> This section is for running MariaDB directly on the host, outside Docker. Most developers should use the Docker workflow described in [dev.md](dev.md) instead.

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