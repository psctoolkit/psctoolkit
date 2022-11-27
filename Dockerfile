FROM ubuntu:latest

WORKDIR /home/work

# Install the needed packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y gcc-10 make cmake mpich git libatlas3-base \
            libatlas-base-dev metis liblapack3 liblapack-dev \
            libsuitesparse-dev libparmetis4.0 libparmetis-dev libmumps-5.4 \
            libsuperlu5 libsuperlu-dev \
            libsuperlu-dist7 libsuperlu-dist-dev \
            nvidia-cuda-toolkit

# First we need to install Metis with 8bytes integer support
ADD http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz /home/work
RUN tar -xvf metis-5.1.0.tar.gz
RUN sed -i 's/#define IDXTYPEWIDTH 32/#define IDXTYPEWIDTH 64/g' metis-5.1.0/include/metis.h
WORKDIR /home/work/metis-5.1.0
RUN make config shared=1 cc=gcc 
RUN make install

WORKDIR /home/work
RUN git clone https://github.com/psctoolkit/psctoolkit.git 
WORKDIR /home/work/psctoolkit 
RUN git submodule update --init --recursive 
RUN git pull

# Install PSBLAS from the repository
WORKDIR /home/work/psctoolkit/psblas3
RUN ./configure \
	--prefix=/usr/local/psctoolkit \
	--with-metisdir=/usr/lib/x86_64-linux-gnu/ \
	--with-blas="-I/usr/include/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/atlas -llapack -lblas" \
	--with-ccopt="-O3 -fPIC -ldl -lgfortran" \
	--with-fcopt="-O3 -frecursive -fPIC -ldl" \
	--with-metisincfile=/usr/local/include/metis.h \
	--with-metisdir=/usr/local/ \
	--with-amddir=/usr/lib/x86_64-linux-gnu/ \
	--with-amdincdir=/usr/include/suitesparse/ 
RUN make 
RUN make install

# Install SPGPU
WORKDIR /home/work/psctoolkit/spgpu/build/cmake
RUN sh configure.sh
RUN make
WORKDIR /home/work/psctoolkit/spgpu
RUN cp lib/* /usr/local/psctoolkit/lib/
RUN cp src/core/*.h /usr/local/psctoolkit/include/

# Install PSBLAS-EXT from the repository
WORKDIR /home/work/psctoolkit/psblas3-ext
RUN mkdir include
RUN mkdir modules
RUN mkdir lib
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
	--with-libs="-L/usr/lib/x86_64-linux-gnu -Wl,--no-as-needed -lpthread -lm -ldl -llapack -lf77blas -lcblas -latlas -fPIC" \
	--with-extra-libs="-L/usr/lib/x86_64-linux-gnu -lm -lparmetis -lmetis -fPIC -ldl" \
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
