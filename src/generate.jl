export generate_deffile

# todo: add options (files for compiling, precompiling, and just using the work folder)
# last one is yet to be figured out
function generate_deffile(; excludepkgs = [], commit = "master")
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

        %setup
            git clone \
            --depth 1 \
            --filter=combine:blob:none+tree:0 \
            --no-checkout \
            "file://$(pwd)" \
            ${SINGULARITY_ROOTFS}/Project
        """))

        if commit != "master"
            println(depsjl_file, (raw"""
                cd ${SINGULARITY_ROOTFS}/Project
            """))
            println(depsjl_file, ("""
                git fetch --depth 1 origin $commit
            """))
        end

        println(depsjl_file, strip(raw"""
        %post
            export JULIA_DEPOT_PATH=/opt/.julia
            export PATH=/opt/julia/bin:$PATH

            cd Project
        """))

        # these are the variable things, unfortunately singularity build does not take arguments
        if commit == "master"
            println(depsjl_file, (raw"""
                git checkout master -- src/ scripts/ Project.toml Manifest.toml
            """))
        else
            println(depsjl_file, (raw"""
                git checkout FETCH_HEAD -- src/ scripts/ Project.toml Manifest.toml
            """))
        end

        println(depsjl_file, ("""
            julia --project -e 'using Pkg; Pkg.rm.($excludepkgs)'
        """))


        println(depsjl_file, (raw"""
            julia --project -e 'using Pkg; Pkg.instantiate()'

            julia --project -e 'using Pkg; for pkg in collect(keys(Pkg.installed()))
                Base.compilecache(Base.identify_package(pkg))
            end'

            chmod -R a+rX $JULIA_DEPOT_PATH
            chmod -R a+rX /Project/scripts

        %runscript
            if [ -z "$@" ]; then
                # if theres none, test julia:
                julia --project=/Project -e 'using Pkg;  Pkg.status()'
            else
                # if theres an argument, then run it! and hope its a julia script :)
                julia --project=/Project "/Project/scripts/$@" > "$@-$(date +"%FT%H%M%S").log"
            fi
        """))
    end

end