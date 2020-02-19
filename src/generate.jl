export generate_deffile

# todo: add options (files for compiling, precompiling, and just using the work folder)
# last one is yet to be figured out
function generate_deffile(; excludepkgs = [])
    ppath = dirname(Base.active_project(false))
    cpath = joinpath(ppath, "container")
    if !isdir(cpath)
        mkdir(cpath)
    end

    singjl_path = joinpath(cpath, "Singularity.pack")


    open(singjl_path, "w") do depsjl_file
        println(depsjl_file, strip(raw"""

        Bootstrap: library
        From: crown421/default/juliabase:latest

        %files
            Project.toml 
            Manifest.toml
            src

        %post
            export JULIA_DEPOT_PATH=/opt/.julia
            export PATH=/opt/julia/bin:$PATH
        """))

        println(depsjl_file, ("""\n
            julia --project -e 'using Pkg; Pkg.rm.($excludepkgs)'
        """))

        println(depsjl_file, (raw"""
            julia --project -e 'using Pkg; Pkg.instantiate()'

            julia --project -e 'using Pkg; for pkg in collect(keys(Pkg.installed()))
                Base.compilecache(Base.identify_package(pkg))
            end'

            chmod -R a+rX $JULIA_DEPOT_PATH

        %runscript
            if [ -z "$@" ]; then
                # if theres none, test julia:
                julia --project=/ -e 'using Pkg;  Pkg.status()'
            else
                # if theres an argument, then run it! and hope its a julia script :)
                julia --project=/ "$@"
            fi
        """))
    end

end