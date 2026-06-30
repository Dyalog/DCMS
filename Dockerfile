FROM dyalog/dyalog:20.0

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /tmp/dotnet-install.sh -c 8.0 -i /opt/dotnet
RUN mkdir -p /data && chown dyalog:dyalog /data

ENV DOTNET_ROOT=/opt/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"

USER dyalog
