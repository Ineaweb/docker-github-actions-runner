Param(

)

Begin {
    Set-Location "C:\actions-runner\Agent"

    if (!$env:ActionsRunner_URL) {
        Write-Error "error: missing ActionsRunner_URL environment variable"
        exit 1
    }

    if (!$env:ActionsRunner_TOKEN) {
        Write-Error "error: missing ActionsRunner_TOKEN environment variable"
        exit 1
    }

    if (!$env:ActionsRunner_AGENT) {
        $env:ActionsRunner_AGENT = "Windows_$(hostname)"
    }

    if (!$env:ActionsRunner_WORK) {
        $env:ActionsRunner_WORK = "_work"
    }

    $argagentonce = ""
    if ($env:ActionsRunner_DISPOSE) {
        $argagentonce = "--ephemeral"
    }

    $argpool = ""
    if ($env:ActionsRunner_POOL) {
        $argpool = "--runnergroup $env:ActionsRunner_POOL "
    }

    function Cleanup () {
        if (Test-Path ".\config.cmd") {
            Invoke-Expression "& .\config.cmd remove --unattended $argagentauth"
        }    
    }    
}    

Process {
    Write-Output "Configure Agent ..."

    $addcommand = "& .\config.cmd --unattended --url $env:ActionsRunner_URL --token $env:ActionsRunner_TOKEN --name $env:ActionsRunner_AGENT --work $env:ActionsRunner_WORK $argpool $argagentonce"
    Write-Output $addcommand

    try {
        Invoke-Expression $addcommand
        Invoke-Expression "& .\run.cmd"
    }
    finally {
        Cleanup;
    }
}

End {
    
}