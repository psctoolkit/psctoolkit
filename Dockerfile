FROM nvidia/cuda:12.6.2-base-ubuntu22.04

WORKDIR /home/work

# Install the needed packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y git cmake g++ gfortran nvidia-cuda-toolkit \
    libopenblas-base libopenblas-dev openmpi-bin openmpi-common \
    libopenmpi-dev libsuitesparse-dev metis libmetis-dev \
    libsuperlu5 libsuperlu-dev \
    libsuperlu-dist7 libsuperlu-dist-dev \
    libmumps-5.4 libmumps-dev libmumps-headers-dev
                        
WORKDIR /home/work
RUN git clone https://github.com/psctoolkit/psctoolkit.git 
WORKDIR /home/work/psctoolkit 
RUN git submodule update --init --recursive 
RUN git pull

# Install PSBLAS from the repository
WORKDIR /home/work/psctoolkit/psblas3
RUN ./configure --with-amdlibdir=/usr/lib/x86_64-linux-gnu/ \
	--with-amdincdir=/usr/include/suitesparse/ \
	--with-metislibdir=/usr/lib/x86_64-linux-gnu/ \
	--with-ipk=4 --with-lpk=4 \
	--prefix=/usr/local/psctoolkit
RUN make 
RUN make install

# Install SPGPU
WORKDIR /home/work/psctoolkit/spgpu/build/cmake
RUN sh configure.sh
RUN make -j6
WORKDIR /home/work/psctoolkit/spgpu
RUN cp lib/* /usr/local/psctoolkit/lib/
RUN cp src/core/*.h /usr/local/psctoolkit/include/

# Install PSBLAS-EXT from the repository
WORKDIR /home/work/psctoolkit/psblas3-ext
RUN mkdir include
RUN mkdir modules
RUN mkdir lib
RUN touch compile
RUN ./configure \
	--with-psblas=/usr/local/psctoolkit \
	--prefix=/usr/local/psctoolkit \
	--with-spgpu=/usr/locall/psctoolkit \
	--with-cudacc=50,60,70
RUN make 
RUN make install

# Install AMG4PSBLAS
WORKDIR /home/work/psctoolkit/amg4psblas
RUN ./configure \
	--with-psblas=/usr/local/psctoolkit \
	--prefix=/usr/local/psctoolkit \
	--with-superlulibdir=/usr/lib/x86_64-linux-gnu \
	--with-superluincdir=/usr/include/superlu/ \
	--with-superludistlibdir=/usr/lib/x86_64-linux-gnu \
	--with-superludistincdir=/usr/include/superlu-dist/ \
	--with-mumpslibdir=/usr/lib/x86_64-linux-gnu \
	--with-mumpsincdir=/usr/include \
	--with-umfpackdir=/usr/lib/x86_64-linux-gnu \
	--with-umfpacklibdir=/usr/lib/x86_64-linux-gnu \
	--with-umfpackincdir=/usr/include/suitesparse/ 
RUN make 
RUN make install
