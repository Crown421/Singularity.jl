export generate_deffile

# todo: add options (files for compiling, precompiling, and just using the work folder)
# last one is yet to be figured out
function generate_deffile(; excludepkgs = [], commit = "master", script = [])
    ppath = dirname(Base.active_project(false))
    cpath = joinpath(ppath, "container")
    if !isdir(cpath)
        mkdir(cpath)
        gitignore = joinpath(ppath, ".gitignore")
        io = open(gitignore, "a+");
        println(io, (raw"""

        ########################################
        #               Singularity                #
        ########################################

        *.sif
        container/containerhome
        """))
        close(io)

    end

    singjl_path = joinpath(cpath, "Singularity.pack")


    open(singjl_path, "w") do depsjl_file

        println(depsjl_file, strip(raw"""
        Bootstrap: library
        From: crown421/default/juliabase:latest

        %setup
            dir=`pwd`
            git clone \
            "file://$dir" \
            ${SINGULARITY_ROOTFS}/Project
        """))

        println(depsjl_file, strip(raw"""
        %post
            export JULIA_DEPOT_PATH=/user/.julia
            export PATH=/opt/julia/bin:$PATH

            cd Project
        """))

        # these are the variable things, unfortunately singularity build does not take arguments
        println(depsjl_file, ("""
            git checkout $commit -- src/ scripts/ Project.toml Manifest.toml
        """))

        println(depsjl_file, ("""
            julia --project -e 'using Pkg; Pkg.rm.($excludepkgs)'
        """))


        print(depsjl_file, (raw"""
            julia --project -e 'using Pkg; Pkg.instantiate()'

            julia --project -e 'using Pkg; Pkg.precompile()'

            chmod -R a+rX $JULIA_DEPOT_PATH
            chmod -R a+rX /Project/scripts

        %runscript
            if [ -z "$@" ]; then
        """))
        if isempty(script)
        print(depsjl_file, (raw"""
                # if theres none, test julia:
                julia --project=/Project -e 'using Pkg;  Pkg.status()'
        """))
        else
        print(depsjl_file, ("""
            SCRIPT=$script
        """))
        println(depsjl_file, (raw"""
                # set specific script if given
                julia --project=/Project -e "include(\\\"/Project/scripts/$SCRIPT\\\")" > "$SCRIPT-$(date +"%FT%H%M%S").log"
        """))
        end
        println(depsjl_file, (raw"""
            else
                # if theres an argument, then run it! and hope its a julia script :)
                julia --project=/Project -e "include(\\\"/Project/scripts/$@\\\")" > "$@-$(date +"%FT%H%M%S").log"
            fi
        """))
    end

end