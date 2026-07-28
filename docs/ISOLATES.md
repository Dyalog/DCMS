# ISOLATES
Computing the search index and video recommendations tables is expensive, so to make sure that HTTP requests continue to be served in a timely manner while these are being computed, we compute them in separate CPU processes using the Isolates workspace.

The raw data comes from the SQL database. It is not clear whether database operations are also a source of delay for HTTP requests. We are already undertaking significant refactoring for `BuildCache` to happen in isolates, so we should consider whether its SQL operations should also occur in the isolate process or whether SQL should happen in the main process and the data just transferred to the isolate as function arguments. If SQL queries are significant, then all CRUD operations should be moved to isolate processes as well.

## Test SQL vs HTTP queries.
Start the service.
Use apache benchmark to get request timings.
Run `Admin.TESTS.InsertDummyData` while running 2nd set of timings.
Compare timings.

If SQL queries cause significant delays, make a plan for migrating all CACHE making and CRUD operations into isolates. If not, then only computing BM25F and cosine similarity needs to be factored out into pure functions which are called with the parallel operator.

Running `DCMS.IMPORT.YOUTUBE.RefreshData` while running request timings might give more insight into this potential cost. It might be that tight, heavy loops in index computations causes more thread blocking than SQL queries.
