# PSCToolkit

This repository contains the various libraries that make up the Parallel Sparse Computation Toolkit (PSCToolkit) as submodules. 

- PSBLAS
- PSBLAS-EXT
- AMG4PSBLAS

All the relevant information can be found at: [psctoolkit.github.io](https://psctoolkit.github.io/). Moreover, it contains a version of the SUNDIALS library interfacing the PSCToolkit routines for linear algebra (distributed matrices and vectors), linear solvers and preconditioners.

## How to get

To clone the **the repository in the maintenance versions** do 
```bash
git clone https://github.com/psctoolkit/psctoolkit.git
```
or if you want to use ssh:
```bash
git clone git@github.com:psctoolkit/psctoolkit.git
```
To keep the development version updated with the changes in the individual repositories, use the command: 
```bash
git submodule update --init --recursive
```
or to execute ```git pull``` inside each of the folders to synchronize to the latest version. 

**Warning:** the various submodules point to mutually compatible versions of the library. Branch switching and pull operations could damage compatibility, especially moving into development branches. The easiest way is to download the latest **stable release**. This contains all versions of the packages that can be compiled together. 

## How to install

The possible installation order are:

1) PSBLAS -> PSBLAS-EXT -> AMG4PSBLAS -> SUNDIALS
2) PSBLAS -> AMG4PSBLAS

Each of the libraries contains its own installation instructions. See information on [https://psctoolkit.github.io/libraries/](https://psctoolkit.github.io/libraries/). 

## How to cite

If you use these libraries in the production of scientific articles visit the [publications page](https://psctoolkit.github.io/publication/) on the site to use the correct references. Also [let us know](mailto:eocoe@na.iac.cnr.it) what you used them for and we will be happy to add you to the list of field applications. 
