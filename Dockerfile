LABEL

FROM ubuntu:latest AS build

RUN apt-get -y update && \
    apt-get install -y libmicrohttpd-dev \
        libjansson-dev \
        libssl-dev \
        libsofia-sip-ua-dev \
        libglib2.0-dev \
    	libopus-dev \
        libogg-dev \
        libcurl4-openssl-dev \
        liblua5.3-dev \
    	libconfig-dev  \
        pkg-config \
        libtool \
        automake \
        git \
        meson  \
        ninja-build  \
        sudo \
        wget \
        cmake

WORKDIR "/tmp"
RUN git clone https://gitlab.freedesktop.org/libnice/libnice
WORKDIR "/tmp/libnice"
RUN meson --prefix=/usr build && ninja -C build && sudo ninja -C build install

WORKDIR "/tmp"
RUN wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
RUN tar xfv v2.2.0.tar.gz
WORKDIR "/tmp/libsrtp-2.2.0"
RUN ./configure --prefix=/usr --enable-openssl
RUN make shared_library && sudo make install

WORKDIR "/tmp"
RUN git clone https://github.com/sctplab/usrsctp
WORKDIR "/tmp/usrsctp"
RUN ./bootstrap
RUN ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6
RUN make && sudo make install

WORKDIR "/tmp"
RUN git clone https://libwebsockets.org/repo/libwebsockets
WORKDIR "/tmp/libwebsockets"
RUN git checkout v4.3-stable
RUN mkdir build
WORKDIR "/tmp/libwebsockets/build"
RUN cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
RUN make && sudo make install

WORKDIR "/tmp"
RUN git clone https://github.com/meetecho/janus-gateway.git
WORKDIR "/tmp/janus-gateway"
RUN git checkout v1.3.3
RUN sh autogen.sh
RUN ./configure --prefix=/opt/janus
RUN make
RUN make install
RUN make configs

WORKDIR "/tmp"
RUN git clone https://github.com/megafarad/janus-telephony-kit.git
RUN mkdir janus-telephony-kit-build
WORKDIR "/tmp/janus-telephony-kit-build"
RUN cmake ../janus-telephony-kit
RUN make
RUN make install

FROM ubuntu:latest AS runtime

RUN apt-get -y update && \
    apt-get install -y dumb-init \
        libmicrohttpd12t64 \
        libconfig9 \
        libglib2.0-0 \
        libjansson4 \
        libcurl4 \
        libopus0 \
        libogg0 \
        libsofia-sip-ua0

WORKDIR /opt/janus
COPY --from=build /opt/janus .

WORKDIR /usr/lib/x86_64-linux-gnu
COPY --from=build /usr/lib/x86_64-linux-gnu/libnice.so.10.15.0 .
RUN ln -s /usr/lib/x86_64-linux-gnu/libnice.so.10.15.0 /usr/lib/x86_64-linux-gnu/libnice.so.10

WORKDIR /usr/lib
COPY --from=build /usr/lib/libusrsctp.so.2.0.0 .
COPY --from=build /usr/lib/libusrsctp.la .
COPY --from=build /usr/lib/libusrsctp.a .
RUN ln -s /usr/lib/libusrsctp.so.2.0.0 /usr/lib/libusrsctp.so.2
RUN ln -s /usr/lib/libusrsctp.so.2.0.0 /usr/lib/libusrsctp.so

COPY --from=build /usr/lib/libsrtp2.so.1 .
RUN ln -s /usr/lib/libsrtp2.so.1 libsrtp2.so

COPY --from=build /usr/lib/libwebsockets.a .
COPY --from=build /usr/lib/libwebsockets.so.19 .
RUN ln -s /usr/lib/libwebsockets.so.19 /usr/lib/libwebsockets.so

COPY startup.sh /opt/janus/bin/startup.sh

EXPOSE 10000-10200/udp
EXPOSE 8188
EXPOSE 8088
EXPOSE 8089
EXPOSE 8889
EXPOSE 8000
EXPOSE 7088
EXPOSE 7089

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "exec /opt/janus/bin/startup.sh"]
