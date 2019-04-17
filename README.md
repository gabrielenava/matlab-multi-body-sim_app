# matlab-multi-body-sim_app

Multi-body dynamics simulations, optimizations and controllers developed using the `matlab-multi-body-sim` simulator.

## Operating system

The code has been developed and tested on Ubuntu 18.04.

## Dependencies

- [matlab-multi-body-sim_core](https://github.com/gabrielenava/matlab-multi-body-sim_core), and its dependencies.

- **OPTIONAL:** [matlab_multi-body-sim_models](https://github.com/gabrielenava/matlab-multi-body-sim_models).

## Installation and usage

This repository can be used in two different ways:

- `git clone` or download this repository as standalone repo. In this case, it will be required to manually specify your local paths to the `matlab-multi-body-sim_core` and `matlab-multi-body-sim_models` folders, and to other `external sources` (if there are any). See also the [configLocalPaths](configLocalPaths.m) script.

- Dowload this repository using the [matlab-multi-body-sim_superbuild](https://github.com/gabrielenava/matlab-multi-body-sim_superbuild) **(suggested)**. In this way, the `superbuild` local paths are automatically loaded. 
 
## Structure of the repo

### Tests and guidelines

- [templates](templates): example of how to use the simulator;
- [test-idyntree-wrappers](test-idyntree-wrappers): test the wrappers of the `iDyntree` library.

### Available simulations

- [gravity-compensation](gravity-compensation)
- [momentum-conservation](momentum-conservation)

## Mantainer

Gabriele Nava ([@gabrielenava](https://github.com/gabrielenava)).
