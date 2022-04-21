Builds a new minimal Ruby on Rails project (no database) that is docker-compose ready

Also supports, but not required, [Mutagen](https://github.com/mutagen-io/mutagen/releases/tag/v0.13.1) and [Mutagen-Compose](https://github.com/mutagen-io/mutagen-compose/releases/tag/v0.13.1), so that guard will function efficiently and as expected. Download and add both to your PATH

See [new-ruby-docker/Dockerfile](rails-builder-image/Dockerfile) if you want to enable/disable additional rails features 
 
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

There is also a [sqlserver git branch](https://github.com/ilude/new-ruby-docker/tree/sqlserver) that will build a project that can use Microsoft Sql Server database

and a [services git branch](https://github.com/ilude/new-ruby-docker/tree/services) that includes a more full featured rails project that includes redis,sidekiq,memcache
