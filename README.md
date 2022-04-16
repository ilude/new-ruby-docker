Builds a new Ruby on Rails project that is docker-compose ready

Requires [Powershell Core](https://community.chocolatey.org/packages/powershell-core) (pwsh) and [GNU Make](https://community.chocolatey.org/packages/make)
Both can be installed using [Chocolatey](https://chocolatey.org/)

To run:

```
mkdir C:\projects
cd C:\projects 
git clone https://github.com/ilude/new-ruby-docker.git
cd new-ruby-docker
make foo
```

This will create a new ruby on rails project in C:\projects\foo and open vscode on completion

in vscode open a new terminal (ctrl+`) and run
```
make
```
open a browser and go to [http://localhost:3000/](http://localhost:3000/)
