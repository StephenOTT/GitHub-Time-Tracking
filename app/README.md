sinatra_auth_github
===================

A sinatra extension that provides oauth authentication to github.  Find out more about enabling your application at github's [oauth quickstart](http://developer.github.com/v3/oauth/).

To test it out on localhost set your callback url to 'http://localhost:9393/auth/github/callback'

The gist of this project is to provide a few things easily:

* authenticate a user against github's oauth service
* provide an easy way to make API requests for the authenticated user
* optionally restrict users to a specific github organization
* optionally restrict users to a specific github team

Installation
============

    % gem install sinatra_auth_github

Running the Example
===================
    % gem install bundler
    % bundle install
    % GITHUB_CLIENT_ID="<from GH>" GITHUB_CLIENT_SECRET="<from GH>" bundle exec rackup -p9393

There's an example app in [spec/app.rb](/spec/app.rb).

Example App Functionality
=========================

You can simply authenticate via GitHub by hitting http://localhost:9393

You can check organization membership by hitting http://localhost:9393/orgs/github

You can check team membership by hitting http://localhost:9393/teams/42

All unsuccessful authentication requests get sent to the securocat denied page.

API Access
============

The extension also provides a simple way to access the GitHub API, by providing an
authenticated Octokit::Client for the user.

    def repos
      github_user.api.repositories
    end

For more information on API access, refer to the [octokit documentation](http://rdoc.info/gems/octokit).

Extension Options
=================

* `:scopes`       - The OAuth2 scopes you require, [Learn More](http://gist.github.com/419219)
* `:secret`       - The client secret that GitHub provides
* `:client_id`    - The client id that GitHub provides
* `:failure_app`  - A Sinatra::Base class that has a route for `/unauthenticated`, Useful for overriding the securocat default page.
* `:callback_url` - The path that GitHub posts back to, defaults to `/auth/github/callback`.

Enterprise Authentication
=========================

Under the hood, the `warden-github` portion is powered by octokit.  If you find yourself wanting to connect to a GitHub Enterprise installation you'll need to export two environmental variables.

* OCTOKIT_WEB_ENDPOINT - The web endpoint for OAuth, defaults to https://github.com
* OCTOKIT_API_ENDPOINT - The API endpoint for authenticated requests, defaults to https://api.github.com
