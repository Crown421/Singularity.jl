module Singularity

include("generate.jl")
include("building.jl")
include("reproduce.jl")

using FileIO
using DrWatson

function __init__()
    if !Sys.islinux()
        error("This package currently requires singularity to be installed, 
        which is only available for linux")
        # TODO add check for singularity (even further, add singularity as binary)
    end
end

end # module
