FROM dyalog/techpreview:latest

USER root
RUN /tmp/dotnet-install.sh -c 8.0 -i /opt/dotnet
RUN apt-get update && apt-get install -y zip && apt-get clean && rm -Rf /var/lib/apt/lists/*

USER dyalog
