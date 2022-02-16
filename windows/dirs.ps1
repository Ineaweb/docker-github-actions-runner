function Core () {
    function dirs (
        [string] $baseDir
    ) {
        Write-Output "$baseDir"
        foreach ($vs in ("vs2019")) {
            foreach ($folder in (Get-ChildItem -path ".\derived\$vs" | where-object {$_.Psiscontainer}).Name) {
                Write-Output "$baseDir\$vs\$folder"
            }
        }

        foreach ($versionsLine in Get-Content ".\derived\dotnet\versions" | Where-Object { $_ -notmatch '^\s*#' }) {
            $versionsFields = $versionsLine.Split()
            Write-Output "$baseDir\dotnet\$($versionsFields[0])"
        }
    }

   Set-Location ".\Core"

    foreach ($versionsLine in Get-Content .\versions | Where-Object { $_ -notmatch '^\s*#' }) {
        $versionsFields = $versionsLine.Split()
        Write-Output "Core\$($versionsFields[0])"
        foreach ($releasesLine in Get-Content .\versioned\releases | Where-Object { $_ -notmatch '^\s*#' }) {
            $releasesFields = $releasesLine.Split()
            dirs "Core\$($versionsFields[0])\actionsrunner"
        }    
    }

    Set-Location ..
}

Core
