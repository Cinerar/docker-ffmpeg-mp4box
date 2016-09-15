# FFMPEG + MP4Box Ubuntu 14.04 image
# From https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# And https://gpac.wp.mines-telecom.fr/2015/07/29/gpac-build-mp4box-only-all-platforms/

FROM        ubuntu:14.04

WORKDIR     /tmp

ENV         FFMPEG_VERSION=3.0.2 \
            LAME_VERSION=3.99.5  \
            YASM_VERSION=1.3.0   \
            VPX_VERSION=1.5.0    \
            MP4BOX_VERSION=0.6.0 \
            SRC=/usr/local

RUN         apt-get update && \
            apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
            libtheora-dev libtool libvorbis-dev libxcb1-dev pkg-config texinfo zlib1g-dev \
            cmake mercurial wget git curl bzip2 && \

# yasm
            DIR=yasm && mkdir ${DIR} && cd ${DIR} && \
            wget http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz && \
            tar xzvf yasm-${YASM_VERSION}.tar.gz && \
            cd yasm-${YASM_VERSION} && \
            ./configure --prefix="${SRC}" --bindir="${SRC}/bin" && \
            make && \
            make install && \
            make distclean && \
            rm -rf ${DIR} && \

# libx264
            DIR=x264 && mkdir ${DIR} && cd ${DIR} && \
            wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 && \
            tar xjvf last_x264.tar.bz2 && \
            cd x264-snapshot* && \
            PATH="${SRC}/bin:$PATH" ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --enable-static --disable-opencl && \
            PATH="${SRC}/bin:$PATH" make && \
            make install && \
            make distclean && \
            rm -rf ${DIR}

# libx265
            DIR=x265 && mkdir ${DIR} && cd ${DIR} && \
            hg clone https://bitbucket.org/multicoreware/x265 && \
            cd x265/build/linux && \
            cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${SRC}" -DENABLE_SHARED:bool=off ../../source && \
            make && \
            make install && \
            rm -rf ${DIR} && \

# libfdk_acc
            DIR=fdk_acc && mkdir ${DIR} && cd ${DIR} && \
            git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac && \
            cd fdk-aac && \
            autoreconf -fiv && \
            ./configure --prefix="${SRC}" --disable-shared && \
            make && \
            make install && \
            make distclean && \
            rm -rf ${DIR} && \

# libmp3lame
            DIR=mp3lame && mkdir ${DIR} && cd ${DIR} && \
            curl -L -O http://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.*}/lame-${LAME_VERSION}.tar.gz && \
            tar xzvf lame-${LAME_VERSION}.tar.gz && \
            cd lame-${LAME_VERSION} && \
            ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --disable-shared --enable-nasm && \
            make && \
            make install && \
            make distclean && \
            rm -rf ${DIR} && \

# libopus
            DIR=opus && mkdir ${DIR} && cd ${DIR} && \
            git clone http://git.opus-codec.org/opus.git && \
            cd opus && \
            autoreconf -fiv && \
            ./configure --prefix="${SRC}" --disable-shared && \
            make && \
            make install && \
            make distclean && \
            rm -rf ${DIR} && \

# libvpx
            DIR=vpx && mkdir ${DIR} && cd ${DIR} && \
            wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${VPX_VERSION}.tar.bz2 && \
            tar xjvf libvpx-${VPX_VERSION}.tar.bz2 && \
            cd libvpx-${VPX_VERSION} && \
            PATH="${SRC}/bin:$PATH" ./configure --prefix="${SRC}" --disable-examples --disable-unit-tests && \
            PATH="${SRC}/bin:$PATH" make && \
            make install && \
            make clean && \
            rm -rf ${DIR} && \

# ffmpeg
            DIR=ffmpeg && mkdir ${DIR} && cd ${DIR} && \
            wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
            tar xjvf ffmpeg-snapshot.tar.bz2 && \
            cd ffmpeg && \
            PATH="${SRC}/bin:$PATH" PKG_CONFIG_PATH="${SRC}/lib/pkgconfig" ./configure \
              --prefix="${SRC}" \
              --pkg-config-flags="--static" \
              --extra-cflags="-I${SRC}/include" \
              --extra-ldflags="-L${SRC}/lib" \
              --bindir="${SRC}/bin" \
              --enable-gpl \
              --enable-libass \
              --enable-libfdk-aac \
              --enable-libfreetype \
              --enable-libmp3lame \
              --enable-libopus \
              --enable-libtheora \
              --enable-libvorbis \
              --enable-libvpx \
              --enable-libx264 \
              --enable-libx265 \
              --enable-nonfree && \
            PATH="${SRC}/bin:$PATH" make && \
            make install && \
            make distclean && \
            hash -r && \
            rm -rf ${DIR} && \

# MP4Box
            DIR=mp4box && mkdir ${DIR} && cd ${DIR} && \
            wget https://github.com/gpac/gpac/archive/v${MP4BOX_VERSION}.tar.gz && \
            tar xzvf v${MP4BOX_VERSION}.tar.gz && \
            cd gpac-${MP4BOX_VERSION} && \
            ./configure --static-mp4box --use-zlib=no && \
            make -j4 && \
            make install && \
            ln -s ${SRC}/bin/MP4Box /usr/bin/MP4Box && \
            make distclean && \
            rm -rf ${DIR}