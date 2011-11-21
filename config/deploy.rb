###########################################################################################################
# Capistrano recipe for deploying ExpressionEngine 2.x websites from GitHub using railsless-deploy        #
# By Carl Hoyer - http://carl.hoyer.ca/                                                                   #
#                                                                                                         #
# Inspired by the hard work of ...                                                                        #
# => Dan Benjamin's https://github.com/dan/hivelogic-ee-deploy (EE 1.x)                                   #
# => Pål Brattberg's https://gist.github.com/294247 (railsless-deploy php sample)                         #
###########################################################################################################

# **ASSUMPTIONS**
# 1. You're trying to deploy ExpressionEngine 2.x using Capistrano & railsless-deploy
# 2. System root is above the webroot as per best practices (http://expressionengine.com/user_guide/installation/best_practices.html)
# 3. You're using Leevi Graham's NSM Config Bootstrap for ALL environments (http://ee-garage.com/nsm-config-bootstrap)


######  Your Environments Deployment Settings   ######
###### Change these to match your configuration ######

# the name of your website - should also be the name of the directory
set :application, "example.com"

# the name of your system directory, which you may have customized as per best practices
set :ee_system, "system"

# the path to your new deployment directory on the server
# by default, the name of the application (e.g. "/var/www/sites/example.com")
set :deploy_to, "/www/vhosts/#{application}"

# name of your web document root folder
set :document_root, "htdocs"

# the path to the old (non-capistrano) ExpressionEngine webroot
set :ee_previous_path, "/www/vhosts/#{application}-stale/htdocs"

# the git-clone url for your repository
set :repository,  "git@github.com:you/your-project.git"

# the branch you want to clone (default is master)
set :branch, "master"

# the name of the deployment user-account on the server
set :user, "deployer"




##### Heavy Lifting Happens Below in Conjunction with railsless-deploy #####
##### You shouldn't need to edit below unless you want to tinker

# Additional SCM Settings
set :scm, :git
set :ssh_options, {:forward_agent => true} # enable private keys with git
set :deploy_via, :remote_cache
set :copy_exclude, [".git", ".gitignore"]
set :keep_releases, 3
set :use_sudo, false
set :copy_compression, :bz2
#set :scm_verbose, true # if you're stuck with an old version of git on the server you might need this

# SSH Settings
#default_run_options[:pty] = true # show password requests on windows (http://weblog.jamisbuck.org/2007/10/14/capistrano-2-1)
#default_run_options[:shell] = false

# commands (e.g. git, sh) cannot be found without setting path for me when using a non admin deployer account on OS X 10.6.8 server ** INVESTIGATE WHY THIS IS REQUIRED
default_environment['PATH'] = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/sbin:/usr/local/bin"

# Roles
role :app, "#{application}"
role :web, "#{application}"
role :db,  "#{application}", :primary => true


# Deployment process
after("deploy:setup", "deploy:create_shared")
after("deploy:update", "deploy:cleanup")
after(:deploy, "deploy:copy_bootstrap", "deploy:create_cache", "deploy:create_symlinks", "deploy:set_permissions")

# Custom ExpressionEngine deployment tasks
namespace :deploy do

  desc "EE: Create shared directories and set permissions after initial setup"
  task :create_shared, :roles => [:app] do
    # create upload directories
    run "mkdir -p #{deploy_to}/#{shared_dir}/config"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images/captchas"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images/member_photos"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images/pm_attachments"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images/signature_attachments"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets/images/uploads"
    run "mkdir -p #{deploy_to}/#{shared_dir}/logs"
    # set permissions as per http://expressionengine.com/user_guide/installation/installation.html
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/captchas"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/member_photos"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/pm_attachments"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/signature_attachments"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/uploads"
  end

  desc "EE: Copy user-uploaded content from existing installation to shared directory"
  task :copy_content, :roles => [:app] do
    # copy the content
    run "cp -n #{ee_previous_path}/images/avatars/uploads/* #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads"
    run "cp -n #{ee_previous_path}/images/captchas/* #{deploy_to}/#{shared_dir}/assets/images/captchas"
    run "cp -n #{ee_previous_path}/images/member_photos/* #{deploy_to}/#{shared_dir}/assets/images/member_photos"
    run "cp -n #{ee_previous_path}/images/pm_attachments/* #{deploy_to}/#{shared_dir}/assets/images/pm_attachments"
    run "cp -n #{ee_previous_path}/images/signature_attachments/* #{deploy_to}/#{shared_dir}/assets/images/signature_attachments"
    run "cp -n #{ee_previous_path}/images/uploads/* #{deploy_to}/#{shared_dir}/assets/images/uploads"
    # reset permissions
    run "chmod -R 777 #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads"
    run "chmod -R 777 #{deploy_to}/#{shared_dir}/assets/images/captchas"
    run "chmod -R 777 #{deploy_to}/#{shared_dir}/assets/images/member_photos"
    run "chmod -R 777 #{deploy_to}/#{shared_dir}/assets/images/pm_attachments"
    run "chmod -R 777 #{deploy_to}/#{shared_dir}/assets/images/signature_attachments"
    run "chmod -R 777 #{deploy_to}/#{shared_dir}/assets/images/uploads"
  end
  
  desc "EE: Copy NSM Config Bootstrap to release root from shared"
  task :copy_bootstrap, :roles => [:app] do
    # copy NSM Config Bootstrap file to release root to ensure paths are correct
    run "cp -n #{deploy_to}/#{shared_dir}/config/config_bootstrap.php #{current_release}/config_bootstrap.php"
  end
  
  desc "EE: Create the cache folder"
  task :create_cache, :roles => [:app] do
    # leave cache folder out of SCM. Re-creating ensures a fresh cache with each deployment.
    run "mkdir -p #{current_release}/#{ee_system}/expressionengine/cache"
  end

  desc "EE: Set the correct permissions for the config files and cache folder"
  task :set_permissions, :roles => [:app] do
    # set permissions as per http://expressionengine.com/user_guide/installation/installation.html
    run "chmod 777 #{current_release}/#{ee_system}/expressionengine/cache"
    run "chmod 666 #{current_release}/#{ee_system}/expressionengine/config/config.php"
    run "chmod 666 #{current_release}/#{ee_system}/expressionengine/config/database.php"
  end

  desc "EE: Create symlinks to shared data (eg. config files and uploaded images)"
  task :create_symlinks, :roles => [:app] do
    # the config files
    run "ln -s #{deploy_to}/#{shared_dir}/config/config.php #{current_release}/#{ee_system}/expressionengine/config/config.php" 
    run "ln -s #{deploy_to}/#{shared_dir}/config/database.php #{current_release}/#{ee_system}/expressionengine/config/database.php" 
    # standard image upload directories
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads #{current_release}/#{document_root}/images/avatars/uploads"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/captchas #{current_release}/#{document_root}/images/captchas"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/member_photos #{current_release}/#{document_root}/images/member_photos"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/pm_attachments #{current_release}/#{document_root}/images/pm_attachments"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/signature_attachments #{current_release}/#{document_root}/images/signature_attachments"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/uploads #{current_release}/#{document_root}/images/uploads"
  end

  desc "EE: Clear caches"
  task :clear_cache, :roles => [:app] do
    run "if [ -e #{current_release}/#{ee_system}/expressionengine/cache/db_cache ]; then rm -r #{current_release}/#{ee_system}/expressionengine/cache/db_cache/*; fi"
    run "if [ -e #{current_release}/#{ee_system}/expressionengine/cache/page_cache ]; then rm -r #{current_release}/#{ee_system}/expressionengine/cache/page_cache/*; fi"
    run "if [ -e #{current_release}/#{ee_system}/expressionengine/cache/magpie_cache ]; then rm -r #{current_release}/#{ee_system}/expressionengine/cache/magpie_cache/*; fi"
  end

end