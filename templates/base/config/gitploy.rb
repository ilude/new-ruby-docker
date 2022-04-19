require "gitploy/script"

configure do |c|
  stage :production do
    c.host = "#{ENV['APP_NAME']}.#{ENV['APP_DOMAIN']}"
    c.path = "/apps/#{ENV['APP_NAME']}-production"
    c.user = "vagrant"
    c.local_branch = "master"
    c.remote_branch = "master"
  end
  stage :staging do
    c.host = "#{ENV['APP_NAME']}-staging.#{ENV['APP_DOMAIN']}"
    c.path = "/apps/#{ENV['APP_NAME']}-staging"
    c.user = "vagrant"
    c.local_branch = "staging"
    c.remote_branch = "staging"
  end
end

setup do
  remote do
    # run "mkdir -p #{config.path}"
    run "cd #{config.path}"
    # git_url = `git config --get remote.origin.url`.strip
    # run "git clone #{git_url} . "
    # run "git checkout -t origin/#{config.remote_branch}"
    run "git config --bool receive.denyNonFastForwards false"
    run "git config receive.denyCurrentBranch ignore"
    
  end
end

deploy do
  # check if we are in the correct branch for deployment
  local_branch = `git rev-parse --abbrev-ref HEAD`.chomp
  unless local_branch == config.local_branch
    abort "You are not in the specified branch \e[33m[\e[36m#{config.local_branch}\e[33m]\e[0m for deployments to #{Gitploy.current_stage}!"
  end
  
  # check for unstaged changes 
  unless system("git diff-files --quiet --ignore-submodules --")
    abort "You have unstaged changes in your current working tree!"
  end

  # check for uncommited changes
  unless system ("git diff-index --cached --quiet HEAD --ignore-submodules --")
    abort "You have uncommited changes in your current working tree!"
  end

  # chech that local and origin are in sync
  tracking_branch = `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"`.chomp
  local_hash  = `git rev-parse head`.chomp
  remote_hash = `git rev-parse #{tracking_branch}`.chomp
  merge_base  = `git merge-base #{tracking_branch} #{local_branch}`.chomp
  
  # puts "Local : #{local_hash}"
  # puts "remote: #{remote_hash}"
  # puts "base  : #{merge_base}"

  # puts "1. #{local_hash.eql?(remote_hash)}"
  # puts "2. #{local_hash.eql?(merge_base)}"
  # puts "3. #{remote_hash.eql?(merge_base)}"

  unless local_hash.eql?(remote_hash)
    if local_hash.eql?(merge_base)
      abort "You must do a \e[31mgit pull\e[0m before deployment!"
    elsif remote_hash.eql?(merge_base)
      abort "You must do a \e[31mgit push\e[0m before deployment!"
    else
      abort "Your local branch \e[33m[\e[36m#{local_brach}\e[33m]\e[0m has diverged from it"s tracking branch \e[33m[\e[36m#{tracking_branch}\e[33m]\e[0m. Please fix this before deployment!"
    end
  end

  local_branch = `git rev-parse --abbrev-ref HEAD`.chomp

  push!
  remote do
    run "source /etc/profile" # make sure the environment is setup
    run "source ~/.profile"
    run "cd #{config.path}"
    run "git reset --hard"
    run "git fetch --all"

    # Allow local branch override (i.e. sandbox/training)
    if config.remote_branch == :current_branch
      run "git checkout origin/#{local_branch}"
    end

    run "make update #{Gitploy.current_stage}"

    # only tag if we are in matching local and remote branches (i.e. not sandbox/training)
    if config.remote_branch != :current_branch
      user  = `git config user.name `.gsub("\"", "").strip
      email = `git config user.email`.gsub("\"", "").strip
      run "make tag RAILS_ENV=#{Gitploy.current_stage.upcase} USER=\"#{user}\" EMAIL=#{email}"
    end

    if(Gitploy.current_stage == "production" && File.readlines("Gemfile").grep(/newrelic/).any?)
      command =  "bundle exec newrelic deployments -e #{Gitploy.current_stage} --user=#{email} "
      command += "--revision=" + `git rev-parse --short HEAD`.strip + " " + `git log -1 --pretty=%B`.strip
      run "COMMAND=\"#{command}\" make newrelic-mark production"
    end
  end
end
