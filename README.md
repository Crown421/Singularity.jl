# Singularity

This package provides a rough interface to create singularity containers from DrWatson Projects. 

Currently available is `generate_deffile` to generate an appropriate .def file in the `<project>/container` folder, and `buildsif` to build an image. 

Currently, the commands build a read-only image. This means, that for any changes in the src folder or the manifest the entire image needs to be rebuilt. For projects that are still under more rapid development but want to run on a server, there will be more in the future. 

Assumptions: 
The folder structure contains the following elements
```bash
├── scripts
│   ├── run
├── src
├── <other folders>
├── Project.toml
├── Manifest.toml
```
The src folder will be copied into the container, and it is further assumed that the modules in it are registered as `dev`ed in the project `Manifest.toml`. 


Further work:
- Generate different deffiles
- add signing and pushing
- add tests
- add various error handling and options
- (big) add singularity binary
- (bigger) do some remote builder magic to make this work on windows/ mac (might be easy with Singularity hub)