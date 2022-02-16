function Core () {
    Set-Location ".\Core"

    function update (
        [string] $windowsVersion,
        [string] $agentVersion
    ) {
        Write-Output "    running update for: $windowsVersion $agentVersion"

        $templateDir = ".\"
        $targetDir = "..\Output\Core\$windowsVersion"
        $agentTag = "windows-core-$windowsVersion"
        if ( $agentVersion ) {
            $templateDir = ".\versioned"
            $targetDir += "\actionsrunner"
            $agentTag += "-actionsrunner"
        }
    
        Write-Output "        Target: $targetDir"
        New-Item -Path $targetDir -ItemType Directory -Force > $null

        (Get-Content "$templateDir\dockerfile.template" -Raw).
        Replace('$[WINDOWS_VERSION]', $windowsVersion).
        Replace('$[AGENT_VERSION]', $agentVersion) |
            Set-Content "$targetDir\dockerfile"

        if (Test-Path "$templateDir\*.ps1") {
            Copy-Item "$templateDir\*.ps1" "$targetDir" -Force
        }
    
        if (Test-Path "$templateDir\setup") {
            New-Item -Path "$targetDir\setup" -ItemType Directory -Force > $null
            Copy-Item "$templateDir\setup\*" "$targetDir\setup\" -Force
        }

        if ( $agentVersion ) {
            # foreach ($vs in ("vs2019")) {
            #     $sourcedir = "derived\$vs"
            #     foreach ($folder in (Get-ChildItem -path ".\$sourcedir" | where-object {$_.Psiscontainer}).Name) {
            #         New-Item -Path "$targetDir\$vs\$folder\" -ItemType Directory -Force > $null
            #         (Get-Content ".\$sourcedir\$folder\dockerfile.template" -Raw).
            #         Replace('$[AGENT_TAG]', $agentTag).
            #         Replace('$[WINDOWS_VERSION]', $windowsVersion).
            #         Replace('$[AGENT_VERSION]', $agentVersion) |
            #             Set-Content "$targetDir\$vs\$folder\dockerfile"
            #     }
            # }

            $sourcedir = "derived\dotnet"
            foreach ($versionsLine in Get-Content ".\$sourcedir.\versions" | Where-Object { $_ -notmatch '^\s*#' }) {
                $versionsFields = $versionsLine.Split()
                $outputdir = "$targetDir\dotnet\$($versionsFields[0])\";
                New-Item -Path $outputdir -ItemType Directory -Force > $null
                (Get-Content ".\$sourcedir\dockerfile.template" -Raw).
                Replace('$[AGENT_TAG]', $agentTag).
                Replace('$[WINDOWS_VERSION]', $windowsVersion).
                Replace('$[AGENT_VERSION]', $agentVersion).
                Replace('$[DOTNET_VERSION]', $versionsFields[0]).
                Replace('$[DOTNET_SDK_VERSION]', $versionsFields[1]).
                Replace('$[DOTNET_CORE_CHANNEL]', $versionsFields[2]) |
                    Set-Content ($outputdir + "\dockerfile");
                if (Test-Path "$sourcedir\*.ps1") {
                    Copy-Item "$sourcedir\*.ps1" "$outputdir" -Force
                }
            }
        }
        
        Write-Output "        done."
    }
    
    Write-Output "Starting update..."
    
    foreach ($versionsLine in Get-Content .\versions | Where-Object { $_ -notmatch '^\s*#' }) {
        $versionsFields = $versionsLine.Split()
        update $versionsFields[0]
        foreach ($releasesLine in Get-Content .\versioned\releases | Where-Object { $_ -notmatch '^\s*#' }) {
            update $versionsFields[0] $releasesLine
        }    
    }

    Set-Location ..
    Write-Output "    done."
}

Core
