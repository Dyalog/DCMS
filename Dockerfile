FROM dyalog/dyalog:19.0

USER root

RUN apt-get update && apt-get install -y wget

RUN wget https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-5.3.13-linux-glibc2.12-x86-64bit.tar.gz && \
mkdir mysql-c && tar -xf mysql-connector-odbc-5.3.13-linux-glibc2.12-x86-64bit.tar.gz -C mysql-c --strip-components=1 && \
ls -l mysql-c && \
cp mysql-c/lib/libmyodbc5w.so /usr/lib/

RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
dpkg -i packages-microsoft-prod.deb && \
rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https   \
      dotnet-runtime-8.0 && \
    apt-get clean && rm -Rf /var/lib/apt/lists/*

ADD docker/odbc.ini /etc
RUN chmod 666 /etc/odbc.ini

USER dyalog
