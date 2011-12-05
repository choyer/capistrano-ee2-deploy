Deploying ExpressionEngine 2.x Sites using Git+Capistrano+railsless-deploy+NSM Config Bootstrap
===============================================================================================

The following workflow might help you manage your [ExpressionEngine](http://expressionengine.com/) 2.x projects. By providing a super simple method for deploying your entire site to a production server it eliminates the need for FTP'ing, SSH'ing and VIM'ing files manually on the server when changes are made. It will save you copious amounts of time, allowing you to re-invest that time into making your site even more awesome or learning how to unicycle.

While several resources exist that detail workflows similar to the one presented below, they all appear to be a few years old and deal exclusively with EE 1.x sites. Within those few short years there have been some advances that make deploying an EE site even easier and more powerful. [Dan Benjamin's](http://hivelogic.com) [Deploying ExpressionEngine From Github with Capistrano](http://hivelogic.com/articles/deploying-expressionengine-github-capistrano/) published in June 2009 has been a great influence. The essence of his fantastically detailed workflow carries on here and even some of the technical technical details are the same. You are encouraged to take the time to read his article cover to cover.

Another highly recommended read is [Jesse Bunch's ExpressionEngine + Version Control blog post](http://getbunch.com/post/12702917040/expressionengine-version-control) making the case for using [SCM](http://en.wikipedia.org/wiki/Software_Configuration_Management) on EE sites and introduces an add-on that disables the native EE template editor within the control panel to avoid changes outside SCM.


## Why You Want to Do This!

There's nothing more exhilarating than typing `cap deploy` and watching the magic happen while sitting back sipping a cup of hot cocoa.


## Assumptions

1. You have some familiarity with the [command line](http://wiseheartdesign.com/articles/2010/11/12/the-designers-guide-to-the-osx-command-prompt/)
2. You are familiar with [Git](http://git-scm.com/), [Github](http://github.com) and it's installed and working on your computer. If not then [here](http://help.github.com/), [here](http://gitref.org/) or [here](http://progit.org/) are excellent references.
3. You are deploying an ExpressionEngine 2.x site
4. The EE system root is above the webroot as per [ExpressionEngine best practices](http://expressionengine.com/user_guide/installation/best_practices.html)
5. You are willing to use the EE [NSM Config Bootstrap](http://ee-garage.com/nsm-config-bootstrap) for managing configuration settings of multiple environments via a single file (very handy).


## Installing Capistrano Locally

If you don't already have [Ruby](http://www.ruby-lang.org) installed on your system (OS X already ships with it installed), take a look at the [Ruby downloads page](http://www.ruby-lang.org/en/downloads/) or consider using [RVM](https://rvm.beginrescueend.com/) (even OS X users should consider RVM).

Once you are all set with Ruby, install capistrano via `rubygems` ...

	gem install capistrano
	

## Installing railsless-deploy Locally

Capistrano was originally developed to ease the deployment of [Ruby on Rails](http://rubyonrails.org/) applications. While you could just use plain Capistrano to deploy EE, because of it's evolution for deploying rails apps it has a lot baked into it by default that is rails specific and gets in the way of [deploying a PHP-based site, such as EE, without some modification]((http://theinbetweens.co.uk/articles/capistrano_for_expression_engine_2)).

Enter railsless-deploy a painless why to deploy non-rails apps. Install it via `rubygems` ...

	gem install railsless-deploy


## Keeping EE User Generated Content, Cache & Configs Out of SCM

The following `.gitignore` file will help keep ExpressionEngine 2.x user generated image content, cache clutter and configuration files out of Git.

<script src="https://gist.github.com/1386698.js?file=.gitignore"></script>


## Follow EE Best Practices

The [ExpressionEngine User Guide](http://expressionengine.com/user_guide/) provides some [best practices](http://expressionengine.com/user_guide/installation/best_practices.html) when it comes to securing your EE site. Follow them. Everything written here will work with these practices.


## Add Your EE Site to a Private Github Repository

Because EE is licensed software you are going to have to put it in a private repository. That means you'll need a [paid account](https://github.com/plans). Creating a Github repository is as easy as following [these instructions](http://help.github.com/create-a-repo/).


## Installing Git on Server

You will need to install `Git` on the server you wish to deploy your EE site to. Once that's done carry on ...


## Create a deployer User Account on Server

It is highly recommended that you create a separate user account to run the deployment process under. This allows you to assign only the security permissions absolutely necessary to complete the deployment.

You can name the user account anything you like. I prefer `deployer`.


## Create SSH Keys for deployer & Add them to Github

SSH keys are required to establish a secure connection with Github when pushing/pulling stuff. **This is an important step that connot be skipped.**

Checkout Githubs help docs for full instructions for [mac](http://help.github.com/mac-set-up-git/), [windows](http://help.github.com/win-set-up-git) or [linux](http://help.github.com/linux-set-up-git/).

And to add the deployment SSH keys to Github see the [Deploy Keys help page](http://help.github.com/deploy-keys/)


## railsless-deploy Flavoured Capistrano for your Project

[Download the contents of this repository](https://github.com/choyer/pixolium-ee2-deploy/zipball/master) to the your project root directory. **NO need to run `capify .`**

Change the documented settings in `config/deploy.rb` to match your environment.


## The Capistrano _Shared_ Directory and What to Use it for

Capistrano has a special shared directory that can be used to contain any files that remain mostly static from one deploy to another. This makes it a good candidate to hold the following types of files for your EE site ...

_TODO: detail use of shared directory_


## What is the NSM Config Bootstrap and How to Use it Best With Source Control?

The [NSM Config Bootstrap](http://ee-garage.com/nsm-config-bootstrap) was created by Leevi Graham to support multiple environments using a single EE configuration file.

While you could maintain separate EE config files for each environment, there are enough commonalities between environments (e.g. Site Name, EE license, etc) that having to keep the config files in sync for more than two environments becomes a pain. Typically the only different configuration parameters between environments are the database connection settings.

### Including NSM Config Bootstrap in the config.php & database.php files (aka the correct `require` path)

Assuming NSM Config Bootstrap is in the project root directory (as noted in the next section) the correct code to included in `system/expressionengine/config/config.php & database.php` is

	require(realpath(dirname(__FILE__) . '/../../../config_bootstrap.php'));
	
** As with most config files you should probably keep this OUT of source control. The `.gitignore` file above will do that for you.


## Setup the Directory Structure on the Server

To setup the skeleton directory structure simply run ...

	cap deploy:setup
	
This is **ONLY required the very first time you deploy to a new server**.

The recommended project directory structure and location of key files is as followed (note that not allow of this gets created automatically by running `cap deploy:setup`) ...

	+--example.com [project root]/
	   +--config [from this repo]/
	   |
	   +--system [ee system dir]/
	   |
	   +--htdocs [web root]/
	   |
	   +--templates [ee site templates dir]/
	   |  +--default_site [where you actually put your templates]/
	   |
	   +--static-templates [more on this in the future]/
	   |
	   +--Capfile [from this repo]
	   +--config_bootstrap.php [your customized NSM Config Bootstrap]


## Deploy (Sit Back and Watch the Magic Over and Over)

After committing and pushing changes to your repository via `Git`, deploying the changes from your workstation to production is as easy as running ...

	cap deploy


## Rolling Back a Bad Deployment

Let's look at the hypothetical scenario in which an issue with your site was pushed via a deploy to the production server. The problem was only caught after the new deployment was live and the fix would take more than a few minutes to develop. I know what you're thinking ... "never happens to me. I test my code." Uh huh. Sure. Feel free to skip this part then.

Using railsless-deploy flavoured Capistrano to roll back a bad deploy is as easy as ...

	cap deploy:rollback
	
This will restore code back to the previous version. The only caveat is that this has no effect on any changes made to the database.


## The Future

This is just a start. Some ideas for future inclusion ...

- Deploying/Sync'ing the EE database
- Full multi-environment support (e.g. development, staging) mirroring [NSM Config Bootstrap](http://ee-garage.com/nsm-config-bootstrap). Currently only support for deployment from local to production.