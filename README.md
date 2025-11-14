# PSCToolkit

This repository contains the various libraries that make up the Parallel Sparse Computation Toolkit (PSCToolkit) as submodules. 

- PSBLAS
- AMG4PSBLAS

All the relevant information can be found at: [psctoolkit.github.io](https://psctoolkit.github.io/). Moreover, it contains a version of the SUNDIALS library interfacing the PSCToolkit routines for linear algebra (distributed matrices and vectors), linear solvers and preconditioners.

## How to get

### Stable Version

To clone the **repository in the maintenance versions** do 
```bash
git clone --recurse-submodules https://github.com/psctoolkit/psctoolkit.git
```
or if you want to use ssh:
```bash
git clone --recurse-submodules git@github.com:psctoolkit/psctoolkit.git
```

### Development Branch

To work with the **development branch** (cutting-edge features and latest updates):

```bash
git clone --recurse-submodules https://github.com/psctoolkit/psctoolkit.git
cd psctoolkit
git checkout development
git submodule update --init --recursive
```

To keep the development version updated with the changes in the individual repositories, use the command: 
```bash
git submodule update --recursive --remote
```
or execute `git pull` inside each of the submodule folders to synchronize to the latest version. 

>[!warning]
> The various submodules point to mutually compatible versions of the library. Branch switching and pull operations could damage compatibility.

### Docker

#### Using Pre-Built Images

Each push to the `development` branch automatically builds and publishes a Docker image to [DockerHub](https://hub.docker.com/r/psctoolkit/psctoolkit) via GitHub Actions. The image includes all dependencies and pre-compiled libraries.

To download the latest development image:
```bash
docker pull psctoolkit/psctoolkit:development
```

Launch an interactive shell in the container:
```bash
docker run -it psctoolkit/psctoolkit:development /bin/bash
```

For GPU-enabled containers (requires NVIDIA Docker runtime):
```bash
docker run --gpus all -it psctoolkit/psctoolkit:development /bin/bash
```

The libraries are installed in `/usr/local/psctoolkit` inside the container.

#### Building Docker Image Locally

If you want to build the image on your local machine:

```bash
cd psctoolkit
docker build -t psctoolkit:local .
```

The Dockerfile includes:
- **Base image**: `nvidia/cuda:13.0.2-devel-ubuntu24.04` (CUDA support)
- **System dependencies**: 
  - Build tools: `git`, `cmake`, `g++`, `gfortran`
  - Math libraries: `libopenblas-dev`, `libsuitesparse-dev`, `libmetis-dev`
  - MPI: `openmpi-bin`, `libopenmpi-dev`
  - Direct solvers: `libsuperlu-dev`, `libsuperlu-dist-dev`, `libmumps-dev`
- **Build configuration**:
  - PSBLAS with CUDA support (compute capabilities 60, 70, 80, 89, 90)
  - OpenMP enabled
  - AMG4PSBLAS with SuperLU, SuperLU_DIST, MUMPS, and UMFPACK support

#### Container Features

- **Working directory**: `/home/work/psctoolkit`
- **Installation prefix**: `/usr/local/psctoolkit`
- **Included submodules**: 
  - `psblas3` (development branch)
  - `amg4psblas` (development branch)
  - `sundials` (psblasinterface branch)

To inspect a specific build stage, you can stop at intermediate steps (see Dockerfile for stage names).

## How to install

### Prerequisites

For building from source, you need:

**Required:**
- C/C++ compiler (gcc/g++)
- Fortran compiler (gfortran)
- MPI implementation (OpenMPI or MPICH)
- BLAS/LAPACK library (e.g., OpenBLAS, Intel MKL)

**Optional (but recommended):**
- CUDA Toolkit (for GPU support)
- SuiteSparse (for AMD ordering and UMFPACK)
- METIS (for graph partitioning)
- SuperLU and SuperLU_DIST (direct sparse solvers)
- MUMPS (multifrontal direct solver)

### Building from Source (Development Branch)

1. **Clone and checkout development branch:**
   ```bash
   git clone --recurse-submodules https://github.com/psctoolkit/psctoolkit.git
   cd psctoolkit
   git checkout development
   git submodule update --init --recursive
   ```

2. **Build PSBLAS:**
   ```bash
   cd psblas3
   ./configure --prefix=/usr/local/psctoolkit \
       --with-amdlibdir=/usr/lib/x86_64-linux-gnu/ \
       --with-amdincdir=/usr/include/suitesparse/ \
       --with-metislibdir=/usr/lib/x86_64-linux-gnu/ \
       --with-ipk=4 --with-lpk=4 \
       --enable-openmp
   
   # For CUDA support, add:
   # --enable-cuda \
   # --with-cudadir=/usr/local/cuda \
   # --with-cudacc=60,70,80,89,90
   
   make -j$(nproc)
   make install
   cd ..
   ```

3. **Build AMG4PSBLAS:**
   ```bash
   cd amg4psblas
   ./configure --prefix=/usr/local/psctoolkit \
       --with-psblas=/usr/local/psctoolkit \
       --with-superlulibdir=/usr/lib/x86_64-linux-gnu \
       --with-superluincdir=/usr/include/superlu/ \
       --with-superludistlibdir=/usr/lib/x86_64-linux-gnu \
       --with-superludistincdir=/usr/include/superlu-dist/ \
       --with-mumpslibdir=/usr/lib/x86_64-linux-gnu \
       --with-mumpsincdir=/usr/include \
       --with-umfpacklibdir=/usr/lib/x86_64-linux-gnu \
       --with-umfpackincdir=/usr/include/suitesparse/
   
   make -j$(nproc)
   make install
   cd ..
   ```

4. **(Optional) Build SUNDIALS with PSBLAS interface:**
   ```bash
   cd sundials
   # Follow instructions in sundials/README.md
   ```

**Note:** Adjust library paths according to your system configuration. The paths shown above are typical for Ubuntu/Debian systems.

### Installation Order

The libraries must be installed in the following order:

1) PSBLAS → AMG4PSBLAS
2) PSBLAS → AMG4PSBLAS → SUNDIALS

Each library contains detailed installation instructions. See [https://psctoolkit.github.io/libraries/](https://psctoolkit.github.io/libraries/) for complete documentation. 

## How to cite

If you use these libraries in the production of scientific articles visit the [publications page](https://psctoolkit.github.io/publication/) on the site to use the correct references. Also [let us know](mailto:psctoolkit@na.iac.cnr.it) what you used them for and we will be happy to add you to the list of field applications. 
