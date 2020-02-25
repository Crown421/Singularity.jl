export buildsif

# todo: as soon as there are option for file generation, take same options here
# could possibly make g take arguments to be interpolated?
function buildsif(;verbose = false, force = true)
    ppath = dirname(Base.active_project(false))

    if force
        cmd = `sudo singularity build --force container/projectcontainer.sif container/Singularity.pack`
    elseif !verbose
        @warn("Image already exists. To overwrite run verbose = true, or force = true")
        return
    else
        cmd = `sudo singularity build container/projectcontainer.sif container/Singularity.pack`
    end
    
    g() = verbose ? run(cmd) : run(pipeline(cmd, stdout="container/pack.log"))

    try
        cd(g, ppath)
    catch
        # if !verbose
        @warn("Build failed")
    end

end