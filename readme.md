Deploying ExpressionEngine 2.x Sites using Git+Capistrano+railsless-deploy+NSM Config Bootstrap
===============================================================================================

The following workflow might help you manage your [ExpressionEngine](http://expressionengine.com/) 2.x projects. By providing a super simple method for deploying your entire site to a production server it eliminates the need for FTP'ing, SSH'ing and VIM'ing files manually on the server every time a change is required. It will save you copious amounts of time, allowing you to re-invest that time into making your site even more awesome or learning how to unicycle.

While several resources exist that detail workflows similar to the one presented below, they all appear to be a few years old and deal exclusively with EE 1.x sites. Within those few short years there have been some advances that make deploying an EE site even easier and more powerful. [Dan Benjamin's](http://hivelogic.com) [Deploying ExpressionEngine From Github with Capistrano](http://hivelogic.com/articles/deploying-expressionengine-github-capistrano/) published in June 2009 has been a great influence. The essence of his fantastically detailed workflow carries on here and even some of the technical technical details are the same. You are encouraged to take the time to read his article cover to cover.

Another highly recommended read is [Jesse Bunch's ExpressionEngine + Version Control blog post](http://getbunch.com/post/12702917040/expressionengine-version-control) making the case for using version control on EE sites and introducing an add-on that disables the native EE template editor within the control panel.


## Why You Want to Do This!

Short answer: There's nothing more exhilarating than typing `cap deploy` and watching the magic happen while sitting back sipping a cup of hot cocoa.


## Assumptions

1. You have some familiarity with the [command line](http://wiseheartdesign.com/articles/2010/11/12/the-designers-guide-to-the-osx-command-prompt/)
2. You are deploying an ExpressionEngine 2.x site
3. The EE system root is above the webroot as per [ExpressionEngine best practices](http://expressionengine.com/user_guide/installation/best_practices.html)
4. You are willing to use the EE [NSM Config Bootstrap](http://ee-garage.com/nsm-config-bootstrap)


## Installing Git Locally

To use Git as your SCM you will likely need to install it first as it doesn't typically come pre-installed. Here are some options for installing it on your local development computer:

### Via Homebrew on OS X

Consider [Homebrew](http://mxcl.github.com/homebrew/). You'll also need Apple's Xcode installed via [App Store for OS X 10.7 Lion](http://itunes.apple.com/us/app/xcode/id448457090?mt=12) OR [Apple Developer Site](http://developer.apple.com/devcenter/mac/index.action) for OS X 10.6 Snow Leopard and earlier. You can grab a pint of your favourite brew while waiting. Once you've got Homebrew and Xcode on your computer installing git is as simple as

	brew install git
	
It doesn't get much easier than that.

### Debian flavoured Linux (Ubuntu)

	apt-get install git-core

### Other platforms via http://git-scm.com/

For those of you using some other flavour of OS or if you simply don't want to use [Homebrew](http://mxcl.github.com/homebrew/) on OS X head on over to the [Git website](http://git-scm.com/). All the instructions are just waiting for you.


If you are brand new to Git you can check out [this](http://help.github.com/), [this](http://gitref.org/) & maybe even [this](http://progit.org/).


## Installing Capistrano Locally

If you don't already have [Ruby](http://www.ruby-lang.org) installed on your system (OS X already ships with it installed), take a look at the [Ruby downloads page](http://www.ruby-lang.org/en/downloads/) and consider using [RVM](https://rvm.beginrescueend.com/) (even OS X users should consider RVM).

Once you are all set with Ruby, install capistrano via `rubygems` ...

	gem install capistrano
	

## Installing railsless-deploy Locally

Capistrano was originally developed to ease the deployment of [Ruby on Rails](http://rubyonrails.org/) applications. While you could just use plain Capistrano to deploy EE, because of it's evolution for deploying rails apps it has a lot baked into it by default that is rails specific and gets in the way of [deploying a PHP-based site, such as EE, without some modification]((http://theinbetweens.co.uk/articles/capistrano_for_expression_engine_2)).

Enter railsless-deploy a painless why to deploy non-rails apps. Install it via `rubygems` ...

	gem install railsless-deploy


## Keeping EE User Generated Content & Cache Out of SCM

The following `.gitignore` file will help keep ExpressionEngine 2.x user generated image content and cache clutter out of Git.

<script src="https://gist.github.com/1386698.js?file=.gitignore"></script>


## Follow EE Best Practices

The [ExpressionEngine User Guide](http://expressionengine.com/user_guide/) provides some [best practices](http://expressionengine.com/user_guide/installation/best_practices.html) when it comes to securing your EE site. Follow them. Everything written here will work with these practices.


## Add Your EE Site to a Private Github Repository

Because EE is licensed software you are going to have to put it in a private repository. That means you'll need a [paid account](https://github.com/plans). Creating a Github repository is as easy as following [these instructions](http://help.github.com/create-a-repo/).


## Installing Git on Server

Again, if you are running OS X on the server consider installing [homebrew](http://mxcl.github.com/homebrew/) and then installing git is as simple as ...

	brew install git

For Debian flavoured Linux distributions like Ubuntu ...

	apt-get install git-core
	
All others see [Git website](http://git-scm.com/) for alternative installation options.


## Create a deployer User Account on Server

It is highly recommended that you create a separate user account to run the deployment process under. This allows you to assign only the security permissions absolutely necessary to complete the deployment.

You can name the user account anything you like. I prefer `deployer`.


## Create SSH Keys for deployer & Add them to Github

_TODO: generate SSH key instructions to go here_

To add the deployment SSH keys to Github see the [Deploy Keys help page](http://help.github.com/deploy-keys/)


## railsless-deploy Flavoured Capistrano for your Project

[Download the contents of this repository](https://github.com/choyer/pixolium-ee2-deploy/zipball/master) to the root directory of you project. **NO need to run `capify .`**

Change the settings as in `config/deploy.rb` to match your environment.


## The Capistrano _Shared_ Directory and What to Use it for

Capistrano has a special shared directory that can be used to contain any files that remain mostly static from one deploy to another. This makes it a good candidate to hold the following files for your EE site ...

_TODO: detail use of shared directory_


## What is the NSM Config Bootstrap and How to Use it Best With Source Control?

[NSM Config Bootstrap](http://ee-garage.com/nsm-config-bootstrap) was created by Leevi Graham to support multiple environments using a single EE configuration file.

While you could maintain the EE config files manually for each environment, there are enough commonalities amongst environments (e.g. Site Name, EE license, etc) that having to keep the config files in sync for more than two environments will quickly become a chore.

shared -> copy to -> project root


## Setup the Directory Structure on the Server

To setup the skeleton directory structure simply run ...

	cap deploy:setup
	
This is **ONLY required the very first time you deploy to a new server**.


## Deploy (Sit Back and Watch the Magic Over and Over)

After committing and pushing modifications via `Git`, deploying the changes to production is as easy as ...

 cap deploy


## Rolling Back a Bad Deployment

Let's look at the hypothetical scenario in which an issue with your site was pushed via a deploy to the production server. The problem was only caught after the new deployment was live and the fix would take more than a few minutes to develop. I know what you're thinking ... "never happens to me. I test my code." Uh huh. Sure. Feel free to skip this part then.

Using railsless-deploy flavoured Capistrano to roll back a bad deploy is as easy as ...

	cap deploy:rollback
	
This will restore code back to the previous version. The only caveat is that this has no effect on any changes made to the database.


## The Future

This is just a start. Some ideas for future inclusion ...

- Deploying/Sync'ing the EE database
- Full multi-environment support (e.g. development, staging) mirroring [NSM Config Bootstrap](http://ee-garage.com/nsm-config-bootstrap). Currently 