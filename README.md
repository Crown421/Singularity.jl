# Singularity

This package provides a rough interface to create [Singularity containers](https://github.com/sylabs/singularity) from DrWatson Projects. 
As fully featured Singularity is only available for linux, this package really only makes sense there.


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
    servertransfer(host)
```
Transfers the image to the `host` into a folder in the home directory of the same name as the project folder. This assumed that everything is configured such that `ssh host` just works. 


### Git setting
To (shallow) clone via commit hash, it is necessary to set the following setting
```
git config --global uploadpack.allowReachableSHA1InWant true
```
This is somewhat unsafe however and not extremely efficient, because there might be a lot of commits, making the search for the right one inefficient, see also [here](https://stackoverflow.com/questions/26135216/why-isnt-there-a-git-clone-specific-commit-option) 
The safety concern appear to mostly focus on git servers however, and this only affects the local git install, as the container clones from the local repo. 


## Further info
Currently, the commands build a single read-only image. This means, that after any change in the project the entire image needs to be rebuilt. This is partly as intended, as the result is a tamper-proof complete environment, that can be used at any point in the future the return the exact same results. 
However for projects that are still under more rapid development, I have possible ideas to make that initial phase not require frequent lengthy rebuilds. 


## Further work:
- Generate different def files
- add interaction with singularity cloud and hub (pushing and pulling)
- signing
- add tests
- add various error handling and options
- (big) add singularity binary ?
- (bigger) do some remote builder magic to make this work on windows/ mac
  - Automate image build on repo push, as mentioned on [singularity hub](https://singularityhub.github.io/singularityhub-docs/docs/builds/automated)