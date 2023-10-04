FROM dyalog/dyalog:18.2

USER root

RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
dpkg -i packages-microsoft-prod.deb && \
rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https   \
      dotnet-runtime-3.1 && \
    apt-get clean && rm -Rf /var/lib/apt/lists/*

ADD docker/entrypoint /
ADD docker/odbc.ini /etc
RUN chmod 666 /etc/odbc.ini

USER dyalog
