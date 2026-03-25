FROM dyalog/techpreview:latest

USER root
RUN /tmp/dotnet-install.sh -c 8.0 -i /opt/dotnet
RUN apt-get update && apt-get install -y zip && apt-get clean && rm -Rf /var/lib/apt/lists/*
RUN mkdir -p /data && chown dyalog:dyalog /data

ENV DOTNET_ROOT=/opt/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"

USER dyalog
