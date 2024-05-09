$current_directory = $PSScriptRoot
$git_path = $current_directory+"\.git"
$commit_path = $git_path+"\commits"
$add_path = $git_path+"\add.txt" 
function init {
    if (-not (Test-Path -Path $git_path)){
        New-Item -Path $git_path -ItemType Directory
    } else {
        Write-Host "Error: git already initiated on current repository"
    }
}

function add {
    Param (
        [string] $File = "."
    )

    if (-not (Test-Path -Path $git_path"\add.txt")){
        New-Item -Path $git_path"\add.txt" -ItemType File
    }

    if ($File -ne ".") {
        Add-Content -Path $git_path"\add.txt" -Value $File
    } else {
        foreach($file_ in (Get-ChildItem -Path $git_path"\.." -Name)){
            if ($file_ -ne ".git") {
                if ($file_ -ne "git.ps1") {
                    Add-Content -Path $git_path"\add.txt" -Value $file_
                }
            }
        }  
    }
}

function commit {
    Param (
        [string] $m
    )

    if (-not (Test-Path -Path $git_path"\commits")){
        New-Item -Path $git_path"\commits" -ItemType Directory
    }

    $add_files = Get-Content -Path $add_path

    $add_files.GetType() | Format-Table -AutoSize

    $items = Get-ChildItem -Path $commit_path

    if ($items.Count -eq 0) {
        Write-Host "Directory empty, first commit created"

        New-Item -Path $commit_path"\$m" -ItemType Directory

        foreach($file in $add_files){
            Copy-Item -Path $current_directory"\$file" -Destination $commit_path"\$m" -Recurse
        }
    } else {
        $latest = (Get-ChildItem $commit_path | Sort-Object -Descending -Property LastWriteTime | Select -First 1 )

        New-Item -Path $commit_path"\$m" -ItemType Directory
        
        Copy-Item -Path $commit_path"\$latest\*" -Destination $commit_path"\$m" -Recurse

        foreach($file in $add_files){
            Copy-Item -Path $current_directory"\$file" -Destination $commit_path"\$m" -Recurse
        }
    }

    Clear-Content -Path $add_path
}
