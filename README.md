# Multi Body Simulator (MBS) App

Multi-body dynamics simulations developed using the `multi-body-simulator`.

## Operating system

The code has been developed and tested on Ubuntu 18.04.5 with MATLAB 2020a.

## Dependencies

- [mbs_core](https://github.com/gabrielenava/mbs_core), and its dependencies.

- **OPTIONAL:** [mbs_models](https://github.com/gabrielenava/mbs_models).

- **OPTIONAL:** [whole-body-controllers library](https://github.com/robotology/whole-body-controllers/tree/master/library/matlab-wbc/%2Bwbc).

## Installation and usage

This repository can be installed in two different ways:

- `git clone` or download this repository as standalone repo. In this case, it is required to manually specify your local paths to the `mbs_core` and `mbs_models` folders, and to other `external sources` (if there are any).

- Download this repository using the [mbs_superbuild](https://github.com/gabrielenava/mbs_superbuild) **(suggested)**. In this way, the local paths are automatically set. **Note**: path to the optional WBC library is not set automatically. 
 
## Structure of the repo

### Testing

- [test-idyntreeWrappers](test-idyntreeWrappers): test the wrappers of the `iDyntree` library.

### Available simulations

- [gravComp-fixed-multiBody](gravComp-fixed-multiBody)
- [freeFalling-singleBody](freeFalling-singleBody)

### Post processing and data analysis

- [dataAnalyzer](dataAnalyzer)

## Mantainer

Gabriele Nava ([@gabrielenava](https://github.com/gabrielenava)).
