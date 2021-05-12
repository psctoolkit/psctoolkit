FROM ubuntu:latest

WORKDIR /home/work

# Install the needed packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y gcc-10 make cmake mpich git libatlas3-base \
            libatlas-base-dev metis liblapack3 liblapack-dev \
            libsuitesparse-dev libparmetis4.0 libparmetis-dev libmumps-5.2.1 \
            libsuperlu5 libsuperlu-dev \
            libsuperlu-dist6 libsuperlu-dist-dev

# First we need to install Metis with 8bytes integer support
ADD http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz /home/work
RUN tar -xvf metis-5.1.0.tar.gz
RUN sed -i 's/#define IDXTYPEWIDTH 32/#define IDXTYPEWIDTH 64/g' metis-5.1.0/include/metis.h
RUN cd metis-5.1.0 && make config shared=1 cc=gcc && make install

RUN ls

# Install PSBLAS from the repository
RUN cd /home/work/psctoolkit/psblas3 && ./configure \
                      --prefix=/usr/local/psctoolkit \
                      --with-metisdir=/usr/lib/x86_64-linux-gnu/ \
                      --with-blas="-I/usr/include/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/atlas -llapack -lblas" \
                      --with-ccopt="-O3 -fPIC -ldl -lgfortran" \
                      --with-fcopt="-O3 -frecursive -fPIC -ldl" \
                      --with-metisincfile=/usr/local/include/metis.h \
                      --with-metisdir=/usr/local/ \
                      --with-amddir=/usr/lib/x86_64-linux-gnu/ \
                      --with-amdincdir=/usr/include/suitesparse/ && make && make install

# Install PSBLAS-EXT from the repository
RUN cd /home/work/psctoolkit/psblas3-ext && ./configure \
                    --with-psblas=/usr/local/psctoolkit \
                    --prefix=/usr/local/psctoolkit && make && make install

# Install AMG4PSBLAS
RUN cd /home/work/psctoolkit/amg4psblas && ./configure \
                    --with-psblas=/usr/local/psctoolkit \
                    --prefix=/usr/local/psctoolkit \
                    --with-libs="-L/usr/lib/x86_64-linux-gnu -Wl,--no-as-needed -lpthread -lm -ldl -llapack -lf77blas -lcblas -latlas -fPIC" \
                    --with-extra-libs="-L/usr/lib/x86_64-linux-gnu -lm -lparmetis -lmetis -fPIC -ldl" \
                    --with-superlulibdir=/usr/lib/x86_64-linux-gnu \
                    --with-superluincdir=/usr/include/superlu/ \
                    --with-superludistlibdir=/usr/lib/x86_64-linux-gnu \
                    --with-superludistincdir=/usr/include/superlu-dist/ \
                    --with-mumpsdir=/usr/lib/x86_64-linux-gnu \
                    --with-mumpslibdir=/usr/lib/x86_64-linux-gnu \
                    --with-mumpsincdir=/usr/include/ \
                    --with-umfpackdir=/usr/lib/x86_64-linux-gnu \
                    --with-umfpacklibdir=/usr/lib/x86_64-linux-gnu \
                    --with-umfpackincdir=/usr/include/suitesparse/ && make && make install
