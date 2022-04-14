param([Parameter(Position=0)]$project_name)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

function Check-Path {
	param(
		[Parameter()] [string] $path
	)
  if(Test-Path -path $path) {
    $confirmation = Read-Host -Prompt "$path already exists, would you like to delete it [y/N]"
    if ($confirmation -eq 'y') {
      Remove-Item -LiteralPath $path -Force -Recurse
    }
    else{
      exit 1
    }
  }
}

if ($project_name -and (Split-Path -Path $project_name)) {
  $project_path = Resolve-Path -Path $project_name
  $project_name = Split-Path -Path $project_path -Leaf
  Check-Path -path $project_path
}
elseif($project_name){
  $project_path = [IO.Path]::Combine('C:\Projects', $project_name)
  Check-Path -path $project_path 
}
else {
  do {
    $project_name = $(Read-Host -Prompt 'Enter full path or project name [C:\Projects\<project_name>]').Trim()
  } 
  while([string]::IsNullOrEmpty($project_path))

  # check if this is a path
  if (Split-Path -Path $project_name)
  {
    $project_path = Resolve-Path -Path $project_name
    $project_name = Split-Path -Path $project_path -Leaf
    Check-Path -path $project_path 
  }
  elseif (Test-Path [IO.Path]::Combine('C:\Projects', $project_name)) {
    $project_path = [IO.Path]::Combine('C:\Projects', $project_name)
    Check-Path -path $project_path
  }
  else {
    exit 1
  }
}

$rails_base_path = [IO.Path]::Combine($project_path, 'base')
$build_base_path = [IO.Path]::Combine($project_path, 'build', 'base')
$vscode_path = [IO.Path]::Combine($project_path, '.vscode')

# create project directory structure
New-Item -Type Directory -Path $rails_base_path > $null
New-Item -Type Directory -Path $build_base_path > $null
New-Item -Type Directory -Path $vscode_path > $null

$uid = $(id -u)
$gid = $(id -g) 

docker build -t rails-project-builder ./rails-builder-image/
docker run --rm -it -v ${rails_base_path}:/app  --user ${uid}:${gid} rails-project-builder

Copy-Item -Path './templates/Makefile' -Destination $project_path
Copy-Item -Path './templates/Dockerfile' -Destination $project_path
Copy-Item -Path './templates/docker-compose.*' -Destination $project_path
Copy-Item -Path './templates/docker-entrypoint.sh' -Destination $build_base_path
Copy-Item -Path './templates/Guardfile' -Destination $rails_base_path
Copy-Item -Path './templates/dockerignore' -Destination $(Join-path $project_path '.dockerignore')
Copy-Item -Path './templates/gitignore' -Destination $(Join-path $project_path '.gitignore')
Copy-Item -Path './templates/email_interceptor.rb' -Destination $(Join-path $rails_base_path 'config' 'initializers')
Copy-Item -Path './templates/vscode_tasks.json' -Destination $(Join-path $vscode_path 'tasks.json')
Copy-Item -Path './templates/vscode_launch.json' -Destination $(Join-path $vscode_path 'launch.json')

$current_dir = $(pwd)

cd $project_path
git init
git add .
git commit -m 'initial import'

cd $current_dir
Write-host "Created project $project_name at $project_path"

if (Get-Command 'code') {
  code $project_path
} 
