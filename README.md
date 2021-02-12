# PSCToolkit

This repository contains the various libraries that make up the Parallel Sparse Computation Toolkit (PSCToolkit) as submodules. 

- PSBLAS
- PSBLAS-EXT
- AMG4PSBLAS

All the relevant information can be found at: [psctoolkit.github.io](https://psctoolkit.github.io/).

## How to get

To clone the **development version** do 
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
Otherwise, the easiest way is to download the latest **stable release**. This contains all versions of the packages that can be compiled together. 

## How to cite

If you use these libraries in the production of scientific articles visit the [publications page](https://psctoolkit.github.io/publication/) on the site to use the correct references. Also [let us know](mailto:eocoe@na.iac.cnr.it) what you used them for and we will be happy to add you to the list of field applications. 
