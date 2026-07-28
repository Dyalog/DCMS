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

### Test results
Summary of results of testing with `ab`.

#### Requests only

|# concurrent requests|time (ms)|
|---------------------|---------|
|                   1 |      75 |
|                  10 |     559 |
|                  20 |    1038 |
|                  30 |    1524 |
|                  40 |    2340 |
|                  50 |    2873 |

Quite slow, although most time is now taken converting between JSON. There is already an open issue to address this.

#### While using SQL
Mean requests time jumped to 1005ms for 10 concurrent requests while inserting 300 records. This rose to 2456ms while inserting 1000 records.

Now, in general updates to the main database should be infrequent. At most, daily updates pulled from the YouTube API will cause a slowdown in requests once at the same time every day. However, the slowdown is evident and database interactions should also be run in separate CPU processes to prevent it.

### Raw results
These are the output of running `ab`on the service running locally on the same machine.

#### Requests only

```
$ ab -n 1 -c 1 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient).....done


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      1
Time taken for tests:   0.075 seconds
Complete requests:      1
Failed requests:        0
Total transferred:      3255235 bytes
HTML transferred:       3255084 bytes
Requests per second:    13.35 [#/sec] (mean)
Time per request:       74.921 [ms] (mean)
Time per request:       74.921 [ms] (mean, across all concurrent requests)
Transfer rate:          42430.57 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:    75   75   0.0     75      75
Waiting:       72   72   0.0     72      72
Total:         75   75   0.0     75      75
```

```
$ ab -n 100 -c 10 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient).....done


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      10
Time taken for tests:   5.918 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      325523500 bytes
HTML transferred:       325508400 bytes
Requests per second:    16.90 [#/sec] (mean)
Time per request:       591.848 [ms] (mean)
Time per request:       59.185 [ms] (mean, across all concurrent requests)
Transfer rate:          53712.12 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:    56  559 114.7    571     720
Waiting:       54  557 114.7    570     718
Total:         57  559 114.6    571     720

Percentage of the requests served within a certain time (ms)
  50%    571
  66%    595
  75%    607
  80%    618
  90%    652
  95%    671
  98%    684
  99%    720
 100%    720 (longest request)
```

```
$ ab -n 100 -c 20 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient).....done


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      20
Time taken for tests:   5.797 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      325523500 bytes
HTML transferred:       325508400 bytes
Requests per second:    17.25 [#/sec] (mean)
Time per request:       1159.346 [ms] (mean)
Time per request:       57.967 [ms] (mean, across all concurrent requests)
Transfer rate:          54840.25 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.5      0       2
Processing:    58 1038 283.3   1156    1191
Waiting:       56 1036 283.4   1155    1189
Total:         60 1038 282.9   1157    1191

Percentage of the requests served within a certain time (ms)
  50%   1157
  66%   1160
  75%   1162
  80%   1166
  90%   1171
  95%   1173
  98%   1180
  99%   1191
 100%   1191 (longest request)
```

```
$ ab -n 100 -c 30 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient).....done


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      30
Time taken for tests:   6.057 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      325523500 bytes
HTML transferred:       325508400 bytes
Requests per second:    16.51 [#/sec] (mean)
Time per request:       1817.170 [ms] (mean)
Time per request:       60.572 [ms] (mean, across all concurrent requests)
Transfer rate:          52481.73 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.4      0       2
Processing:    68 1523 523.0   1747    1940
Waiting:       66 1522 523.0   1745    1939
Total:         69 1524 522.6   1747    1940

Percentage of the requests served within a certain time (ms)
  50%   1747
  66%   1781
  75%   1790
  80%   1904
  90%   1920
  95%   1923
  98%   1937
  99%   1940
 100%   1940 (longest request)
```

```
$ ab -n 280 -c 40 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Finished 280 requests


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      40
Time taken for tests:   17.746 seconds
Complete requests:      280
Failed requests:        0
Total transferred:      911465800 bytes
HTML transferred:       911423520 bytes
Requests per second:    15.78 [#/sec] (mean)
Time per request:       2535.183 [ms] (mean)
Time per request:       63.380 [ms] (mean, across all concurrent requests)
Transfer rate:          50157.17 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.9      0       5
Processing:    66 2340 587.5   2421    3024
Waiting:       65 2338 587.4   2418    3022
Total:         71 2340 586.7   2421    3024

Percentage of the requests served within a certain time (ms)
  50%   2421
  66%   2488
  75%   2737
  80%   2774
  90%   2872
  95%   2960
  98%   2989
  99%   3009
 100%   3024 (longest request)
```

```
$ ab -n 300 -c 50 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Finished 300 requests


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      50
Time taken for tests:   18.915 seconds
Complete requests:      300
Failed requests:        0
Total transferred:      976570500 bytes
HTML transferred:       976525200 bytes
Requests per second:    15.86 [#/sec] (mean)
Time per request:       3152.552 [ms] (mean)
Time per request:       63.051 [ms] (mean, across all concurrent requests)
Transfer rate:          50418.53 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    1   1.4      0       7
Processing:    79 2873 744.3   3190    3333
Waiting:       70 2871 744.4   3188    3331
Total:         79 2873 743.0   3190    3333

Percentage of the requests served within a certain time (ms)
  50%   3190
  66%   3239
  75%   3252
  80%   3258
  90%   3273
  95%   3291
  98%   3302
  99%   3317
 100%   3333 (longest request)
```

#### While inserting 300 records

```
ab -n 100 -c 10 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient).....done


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      10
Time taken for tests:   10.580 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      325523500 bytes
HTML transferred:       325508400 bytes
Requests per second:    9.45 [#/sec] (mean)
Time per request:       1058.011 [ms] (mean)
Time per request:       105.801 [ms] (mean, across all concurrent requests)
Transfer rate:          30046.38 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       0
Processing:    84 1024 1288.8    594    5192
Waiting:       82 1022 1288.7    592    5184
Total:         85 1024 1288.8    594    5192

Percentage of the requests served within a certain time (ms)
  50%    594
  66%    606
  75%    616
  80%    627
  90%   3002
  95%   5162
  98%   5173
  99%   5192
 100%   5192 (longest request)
```

#### While inserting 1000 records

```
$ ab -n 100 -c 10 "http://localhost:8081/videos?search=lorem+ipsum&per_page=100"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient).....done


Server Software:        Jarvis
Server Hostname:        localhost
Server Port:            8081

Document Path:          /videos?search=lorem+ipsum&per_page=100
Document Length:        3255084 bytes

Concurrency Level:      10
Time taken for tests:   24.921 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      325523500 bytes
HTML transferred:       325508400 bytes
Requests per second:    4.01 [#/sec] (mean)
Time per request:       2492.086 [ms] (mean)
Time per request:       249.209 [ms] (mean, across all concurrent requests)
Transfer rate:          12756.14 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:    75 2456 5234.2    608   19406
Waiting:       71 2454 5234.2    607   19404
Total:         75 2456 5234.2    609   19406

Percentage of the requests served within a certain time (ms)
  50%    609
  66%    622
  75%    639
  80%    643
  90%  11955
  95%  19371
  98%  19394
  99%  19406
 100%  19406 (longest request)
```
