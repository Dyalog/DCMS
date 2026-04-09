FROM dyalog/techpreview:latest

USER root
RUN /tmp/dotnet-install.sh -c 8.0 -i /opt/dotnet
RUN apt-get update && apt-get install -y zip curl && apt-get clean && rm -Rf /var/lib/apt/lists/*
RUN mkdir -p /data && chown dyalog:dyalog /data
RUN DEBFILE=`curl -o - -s https://www.dyalog.com/uploads/php/download.dyalog.com/download.php?file=docker.metafile | grep x86_64 | awk -v v="$DYALOG_RELEASE" '$0~v && /deb/ {print $3}'` ;\
    curl -o /tmp/dyalog.deb ${DEBFILE}
ADD rmfiles.sh /
RUN ls /tmp/dyalog.deb
RUN dpkg -i --ignore-depends=libtinfo5 /tmp/dyalog.deb

ENV DOTNET_ROOT=/opt/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"

USER dyalog

