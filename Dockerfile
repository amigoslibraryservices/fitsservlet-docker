FROM tomcat:9.0.102-jre17-temurin-jammy as fits-base-stage

RUN apt-get update && \
    apt-get install -yqq make gcc unzip

ARG FILE_VERSION=5.43
ARG FILE_SHA256=8c8015e91ae0e8d0321d94c78239892ef9dbc70c4ade0008c0e95894abfb1991

RUN cd /var/tmp && \
    mkdir file && \
    curl -sL https://astron.com/pub/file/file-${FILE_VERSION}.tar.gz -o file-${FILE_VERSION}.tar.gz && \
    echo "${FILE_SHA256}  file-${FILE_VERSION}.tar.gz" | sha256sum --check && \
    tar zxf file-${FILE_VERSION}.tar.gz && cd file-${FILE_VERSION} && \
    ./configure && make -j$(nproc) && make install DESTDIR=/var/tmp/file

ARG FITS_VERSION=1.6.0

RUN mkdir /var/tmp/fits && \
    cd /var/tmp/fits && \
    curl -sL https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip -o fits-${FITS_VERSION}.zip && \
    curl -sL https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip.md5 -o fits-${FITS_VERSION}.zip.md5 && \
    md5sum -c fits-${FITS_VERSION}.zip.md5 && \
    unzip fits-${FITS_VERSION}.zip

ARG FITSSERV_VERSION=2.1.0

RUN cd /var/tmp && \
    curl -sL https://github.com/harvard-lts/fitsservlet/releases/download/${FITSSERV_VERSION}/fits-service-${FITSSERV_VERSION}.war -o fits-service-${FITSSERV_VERSION}.war && \
    curl -sL https://github.com/harvard-lts/fitsservlet/releases/download/${FITSSERV_VERSION}/fits-service-${FITSSERV_VERSION}.war.md5 -o fits-service-${FITSSERV_VERSION}.war.md5 && \
    md5sum -c fits-service-${FITSSERV_VERSION}.war.md5 && \
    mv fits-service-${FITSSERV_VERSION}.war fits.war

FROM tomcat:9.0.102-jre17-temurin-jammy

RUN apt-get update && \
    apt-get install -yqq \
    # jpylyzer dependencies
    python3 \
    python-is-python3 \
    # exiftool dependencies https://github.com/exiftool/exiftool
    libarchive-zip-perl \
    libio-compress-perl \
    libcompress-raw-zlib-perl \
    libcompress-bzip2-perl \
    libcompress-raw-bzip2-perl \
    libio-digest-perl \
    libdigest-md5-file-perl \
    libdigest-perl-md5-perl \
    libdigest-sha-perl \
    libposix-strptime-perl \
    libunicode-linebreak-perl\
    # mediainfo dependencies
    libmms0 \
    libcurl3-gnutls \
    # mediainfo - comment this if you want to use the AMD64 mediainfo bundled with FITS
    mediainfo \
    && rm -rf /var/lib/apt/lists/*

COPY --from=fits-base-stage /var/tmp/file/usr/local/ /usr/local/
COPY --from=fits-base-stage /var/tmp/fits /opt/fits
COPY --from=fits-base-stage /var/tmp/fits.war ${CATALINA_HOME}/webapps/
COPY conf/ ${CATALINA_HOME}/conf/

RUN mkdir ${CATALINA_HOME}/webapps/ROOT && \
    echo '<% response.sendRedirect("/fits/"); %>' > $CATALINA_HOME/webapps/ROOT/index.jsp && \
    ldconfig && \
    # comment this rm if you want to use the AMD64 mediainfo bundled with FITS
    rm /opt/fits/tools/mediainfo/linux/libzen.so* /opt/fits/tools/mediainfo/linux/libmediainfo.so*
    
