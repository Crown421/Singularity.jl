# Singularity

This package was presented at JuliaCon, and the presentation is available [under this link](https://musing-pare-2ba365.netlify.app/#/).

This package provides a rough interface to create [Singularity containers](https://github.com/sylabs/singularity) from DrWatson Projects. 
This package currently works best on Linux systems, as the build command currently not available on Mac. 

### Basis
This package uses a minimal debian-based container with Julia installed as a base. On the [Sylab cloud](https://cloud.sylabs.io/home) you can find the Juliabase image, and an experimental container also including jupyter
- [juliabase](https://cloud.sylabs.io/library/_container/5e418a1b2758e9ed1175de24): 1.4.2, 1.3.1
- [jupyterbase](https://cloud.sylabs.io/library/_container/5f20adbeae86dd3232dec1d1): 1.4.2

If you would prefer to build them yourself, the def files are available in the `basebuilds` folder. 

### Assumptions: 
The package assumes that that the folder structure contains the following elements
```bash
├── scripts
│   ├── run
├── src
│   ├── module1
│   ├── module2
├── container
├── <other folders>
├── Project.toml
├── Manifest.toml
```
and everything is under the control of a single git repository. This will be automatically the case if the project folder was created by [DrWatson.jl](https://github.com/JuliaDynamics/DrWatson.jl). 

The src and scripts folder will be copied into the container, and it is further assumed that the modules in it are registered as `dev`ed in the project `Manifest.toml`. 

### Warning:
Calling `buildsif` will ask for root privileges, as the underlying `singularity build` commands requires it. This is clearly a potential security risk, so if you are unsure, please inspect the `Singularity.pack` file in the `container` folder. 

## Usage
The package provides the following functions. All these functions work from any folder as long as the correct project environment is loaded. They are also still WIP, so there is very little error checking being done. 

```
    generate_deffile(; excludepkgs = [], commit = "master")
```
Creates the `container` folder if it does not exist yet, and generates the `Singularity.pack` def file. 
- `excludepkgs` accepts and array of package names. These packages will be removed from `Project.toml` inside the container. This is for packages that are needed locally, for example for visualization, but are not needed in the container and would only add bloat. 
- `commit` accept any project commit hash, and will build the container using the `src` and `script` folder from that commit. Requires the git setting below.

```
    buildsif(;verbose = false, force = true)
```
Builds the container image into the `container` folder based on the existing def file. 
- `verbose` sends all the output of the build process to the REPL if set to `true`, otherwise it will be written to file.
- `force` set to `true` causes an existing image to be overwritten without asking for confirmation.

```
    recreatedata(file::String; dir = [])
```
Extracts the git commit hash and script name from a `DrWatson.@tagsave`d file, and generated a def file. The resulting container, when `singularity run`, should recreate the initial file directly. 
- `dir` allows the specification of a subdirectory of the `DrWatson.datadir()` directory.  

```
    servertransfer(host)
```
Transfers the image to the `host` into a folder in the home directory of the same name as the project folder. This assumed that everything is configured such that `ssh host` just works. 



## Further info
Currently, the commands build a single read-only image. This means, that after any change in the project the entire image needs to be rebuilt. This is partly as intended, as the result is a tamper-proof complete environment, that can be used at any point in the future the return the exact same results. 
However for projects that are still under more rapid development, I have possible ideas to make that initial phase not require frequent lengthy rebuilds. 


## Further work:
- Generate different def files
- add interaction with singularity cloud and hub (pushing and pulling)
- signing
- add tests
- add various error handling and options
- (big) do some remote builder magic to make this work on windows/ mac
  - Automate image build on repo push, as mentioned on [singularity hub](https://singularityhub.github.io/singularityhub-docs/docs/builds/automated)
- (bigger) add singularity binary ?