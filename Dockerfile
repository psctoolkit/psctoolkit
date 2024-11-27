# docker pull nvidia/cuda:12.6.1-base-ubuntu24.04
FROM nvidia/cuda:12.6.1-base-ubuntu24.04

WORKDIR /home/work

# Install the needed packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y make cmake mpich git libopenblas-dev \
            libopenblas0 metis \
            libsuitesparse-dev libparmetis4.0 libparmetis-dev libmumps* \
            libsuperlu6 libsuperlu-dev \
            libsuperlu-dist8 libsuperlu-dist-dev \
            libmetis5 libmetis-dev 

# Output nvcc version
RUN nvcc --version
                        
WORKDIR /home/work
RUN git clone https://github.com/psctoolkit/psctoolkit.git 
WORKDIR /home/work/psctoolkit 
RUN git submodule update --init --recursive 
RUN git pull

# Install PSBLAS from the repository
WORKDIR /home/work/psctoolkit/psblas3
RUN ./configure \
	--with-ipk=4 --with-lpk=4 \
	--prefix=/usr/local/psctoolkit \
	--with-metisdir=/usr/lib/x86_64-linux-gnu/ \
	--with-ccopt="-O3 -fPIC -ldl" \
	--with-fcopt="-O3 -frecursive -fPIC -ldl" \
	--with-metisincfile=/usr/local/include/metis.h \
	--with-metisdir=/usr/local/ \
	--with-amddir=/usr/lib/x86_64-linux-gnu/ \
	--with-amdincdir=/usr/include/suitesparse 
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
	--with-libs="-L/usr/lib/x86_64-linux-gnu -Wl,--no-as-needed -lpthread -lm -ldl -lopenblas -fPIC" \
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
