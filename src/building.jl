export buildsif, servertransfer

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
        println("running $cmd")
        cd(g, ppath)
    catch
        # if !verbose
        @warn("Build failed")
    end

end


# ToDo: add 'prefix' to 
function servertransfer(host)
    ppath = dirname(Base.active_project(false))
    pfolder = basename(ppath)

    mkfolder = `ssh greyplover.stats mkdir -p $pfolder/data`
    run(mkfolder)

    transfer = `rsync -azP container/projectcontainer.sif $host:$pfolder`
    g() = run(transfer)
    cd(g, ppath)
end
