FROM nvidia/cuda:13.0.2-devel-ubuntu24.04

WORKDIR /home/work

# Install the needed packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y git cmake g++ gfortran nvidia-cuda-toolkit \
    libopenblas-dev openmpi-bin openmpi-common \
    libopenmpi-dev libsuitesparse-dev metis libmetis-dev \
    libsuperlu6 libsuperlu-dev \
    libsuperlu-dist8 libsuperlu-dist-dev \
    libmumps-5.6t64 libmumps-dev libmumps-headers-dev
                        
WORKDIR /home/work
RUN git clone https://github.com/psctoolkit/psctoolkit.git 
WORKDIR /home/work/psctoolkit 
RUN git checkout development
RUN git submodule update --init

# # Install PSBLAS from the repository
WORKDIR /home/work/psctoolkit/psblas3
RUN ./configure --with-amdlibdir=/usr/lib/x86_64-linux-gnu/ \
	--with-amdincdir=/usr/include/suitesparse/ \
	--with-metislibdir=/usr/lib/x86_64-linux-gnu/ \
	--with-ipk=4 --with-lpk=4 \
	--prefix=/usr/local/psctoolkit \
	--with-cudadir=/usr/local/cuda \
	--with-cudacc=60,70,80,89,90 \
    --enable-cuda \
	--enable-openmp 
RUN make -j4
RUN make install

# # # Install AMG4PSBLAS
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
RUN make -j4
RUN make install
