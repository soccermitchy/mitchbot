local timers={}
function timerStep()
    for k,v in pairs(timers) do
        if v.steps==v.stepsNeeded then 
            v.func()
            v.steps=0
        else
            v.steps=v.steps+1
	end
    end
end

function addTimer(time,exec,name)
    name=name or error'No timer name given'
    exec=exec or error'No function given'
    time=time or error'No time given'
    timers[name]={}
    timers[name].func=exec
    timers[name].steps=0
    timers[name].time=time*0.1
end
