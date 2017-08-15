# Instructions and other stuff casually stolen from https://github.com/gridcoin/Gridcoin-Research.
# Specifically, the build instructions for the gridcoin research client for Ubuntu.

FROM ubuntu
MAINTAINER Vishakh Kumar <vishakhpradeepkumar@gmail.com>

#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get -y update 

# Installing Normal Dependencies. 
RUN apt-get -y install ntp \
                       git \
                       build-essential \
                       libssl-dev \
                       libdb-dev \
                       libdb++-dev \
                       libqrencode-dev \
                       libcurl4-openssl-dev \
                       curl \
                       libzip-dev \
                       libzip4 \
                       libboost-atomic-dev \
                       libboost-chrono-dev \
                       libboost-date-time-dev \
                       libboost-filesystem-dev \
                       libboost-program-options-dev \
                       libboost-serialization-dev \
                       libboost-system-dev \
                       libboost-thread-dev \
		       libboost-all-dev \
                       wget unzip

# Build Gridcoin Daemon.
# We'll be cloning from the github repo and following directions from there.
# Just to be explicit, the directions were found at Gridcoin-Research/doc/build-unix.txt
RUN cd ~ \
    && git clone --depth 256 --branch master --single-branch https://github.com/gridcoin/Gridcoin-Research \
    && cd ~/Gridcoin-Research/src \
    && git checkout $(git describe --abbrev=0 --tags) \
    && mkdir obj \
    && chmod 755 leveldb/build_detect_platform  
RUN make -f makefile.unix USE_UPNP=-  \
    && strip gridcoinresearchd \ 
    && install -m 755 gridcoinresearchd /usr/bin/gridcoinresearchd 
	
RUN mkdir ~/.GridcoinResearch \
 && cd ~/.GridcoinResearch/  \
 && wget http://download.gridcoin.us/download/downloadstake/signed/snapshot.zip -O blockchain.zip \
 && unzip blockchain.zip \
 && rm blockchain.zip
	 

ARG BOINC_DIR=/root/boinc_dir
ARG RPCUSER=user                                          
ARG RPCPASSWORD=ssap 

# add information to gridcoinresearch.conf.
RUN echo 'addnode=node.gridcoin.us\nserver=1                  \n\
rpcuser=$RPCUSER                                              \n\    
rpcpassword=$RPCPASSWORD                                      ' \
>> ~/.GridcoinResearch/gridcoinresearch.conf                    \
    $$ cd ~                                                     \
    && mkdir $BOINC_DIR                                         \
    && cd $BOINC_DIR                                            \
    && pwd

# Run gridcoin daemon
CMD gridcoinresearchd&bash
