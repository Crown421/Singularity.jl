export recreatedata

function recreatedata(file; dir = [])

    if isempty(dir)
        l = load(file)
    else
        l = load(datadir(dir,file))
    end

    startidx = findfirst("/",l[:script])[1]
    endidx = findfirst("#",l[:script])[1]
    scriptname = l[:script][startidx+1:endidx-1]

    commit = l[:gitcommit]

    generate_deffile(; commit = commit, script = scriptname)
end