# misc functions
function epoch(;data,tbl,τ,sfreq,kwargs...)
    epoch(data,tbl,τ,sfreq;kwargs...)
end

function epoch(data::Array{T,2},tbl::DataFrame,τ::Tuple{Number,Number},sfreq;eventtime::Symbol=:latency) where T <:Number
# data: channels x times

# partial taken from EEG.jl

    numEpochs = size(tbl,1)
    times = range(τ[1],stop=τ[2],step=1 ./sfreq)
    lenEpochs = length(times)
    numChans = size(data,1)
    epochs = Array{Union{Missing,Float64}}(missing,Int(numChans),Int(lenEpochs), Int(numEpochs))


    # User feedback
    @debug("Creating epochs: $lenEpochs x $numEpochs x $numChans")

    for si = 1:size(tbl,1)
        #eventonset = tbl[si,eventtime] # in samples
        #d_start = eventonset
        d_start = Int(ceil(tbl[si,eventtime] - sum(times.<0)))
        d_end =  Int(ceil(tbl[si,eventtime]+lenEpochs-1 - sum(times.<0)))
        e_start = 1
        e_end = lenEpochs
        if d_start<1
            e_start = e_start + (d_start+1)
            d_start = 1
        end
        if d_end >size(data,2)
            e_end = e_end - (d_end-size(data,2))
            d_end = size(data,2)
        end
        #println("d: $(size(data)),e: $(size(epochs)) | $d_start,$d_end,$e_start,$e_end | $(tbl[si,eventtime])")
        epochs[:, e_start:e_end,si] = data[:,d_start:d_end]
    end
    return(epochs,times)
end


function dropMissingEpochs(X,y)
    goodIx = dropdims(.!any(ismissing.(y),dims=2),dims=(1,2))
    return X[goodIx,:],Array{Float64}(y[:,:,goodIx])
end
