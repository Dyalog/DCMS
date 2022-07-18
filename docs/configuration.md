# Configuration
Development config in **dev.dcfg**. Runtime config in **run.dcfg**.

1. Set data sources location in **data_sources.json5**
2. Put API keys into a file **on the server only** in **secrets.json5**
3. Set application directory, dependencies etc. in **run.dcfg**
    - app_dir
    - service_url

## data sources
Most manually updated source data is specified in **data_sources.json5**.

Some data is fetched from external APIs. API keys are specified

## debug
Global debug flag. Used as `#.GLOBAL.debug` in order to not have to re-read environment.

This controls behaviour of errors (error number > 0) and warnings (error number < 0) in terms of resignalling and logging.

|Value|Behaviour|
|---|---|
|0|Catch all errors, print errors and warnings to the session log and attempt to carry on.
|1|Stop on errors but just print warnings to the session log|
|2|Stop on errors and warnings|

