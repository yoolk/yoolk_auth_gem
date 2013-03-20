# YoolkAuth

This gem assists with correctly loading and authenticating an application as an external app in Yoolk Core. It provides the external app with details of the user, portal and listing required to bootstrap the app!

## Installation

Add this line to your application's Gemfile

    gem 'yoolk_auth', '0.1.4', :git => 'git://github.com/yoolk/yoolk_auth_gem.git'

And then execute:

    $ bundle

## Tests

Developers can run all tests using the following command:

    cd /var/www/yoolk_auth_gem/
    bundle exec rspec spec --format d

## Application Setup

Add this include statement to your ApplicationController like this:
    
  __include YoolkAuth::Connection__

Add this to your ApplicationHelper

  __include YoolkAuth::Helper__

Add this to your application.js file

  __//= require yoolk_external_app__

Add this to your Routes

    root :to => "home#index" #The root route can be anywhere but recommend it to be home#index
    post 'handshake', :to => 'application#handshake'

Add your APP_KEY and DEVELOPER_KEY constants to your config

    DEVELOPER_KEY = "your-developer-key-from-yoolk-core-team"
    APP_KEY = "your-app-key-from-yoolk-core-team"

When running in DEVELOPMENT environment developers can choose to mock the handshake by adding a specific file under the config directory.
For example, save the following yaml config to: "#{Rails.root}/config/yoolk_auth_connection_mock_config.yaml" (or delete the file if you want to test the real handshake process!).

__remember to restart your app when you first add or remove this file__ You dont need to restart your app if you make changes to the config, however.

Here is a sample set of configurations:

    username: "victory@yoolk.com" #note: set to nil to logout (in YAML nil is ~)
    listing_alias_id: "kh34363"
    portal_domain_name: "cambodiastaging.yoolk.com"
    roles: ["sales"]
    handshake_response_code: "200"
    error_url: "http://yellowpages-cambodia.dev/app/1/error" #error url for core

## Usage

The Gem exposes a number of helper methods that provide information about the user who is accessing your App via Yoolk Core:

    #Is the user logged in to Yoolk Core or not?
    logged_in?

    #What is the username of the user (nil if not logged in)
    username

    #What are the roles of the user (see below for more details)
    roles

    #What is the listing_alias_id of the listing the user is currently viewing in the Yoolk Core
    listing_alias_id

    #The portal domain the user is visiting
    portal_domain_name

## Logged In

You can use the logged_in? method to show content for authenticated users or guest users as the following haml example shows:

    - if logged_in?
      =render 'authenticated'
    - else
      =render 'guest'

Obviously developers can use the username to display the username of the currently logged in user if they wish. Additionaly, of course, listing_alias_id and portal_domain_name can be used to fetch data from the Yoolk Core API accordingly.

## Roles

Handling roles is up to the app developer. The possible list of roles currently are (with some general guidelines):

    yoolk_admin: Can edit anything! e.g. ‘Superuser’
    portal_admin: Can edit anything in a portal
    sales: Can edit assets only. Everything else is read.
    data_operator: Can edit anything except core portal data
    major_content_operator: Can edit listing category and address
    read_only: Can read everything only

It is recommended to use the cancan gem to manage roles in your application. For more details see the cancan gem homepage: <https://github.com/ryanb/cancan/>

## Application URL

The production url pattern will be as follows. It's recommended to use the same pattern (but with a .dev extention) during development. Some examples:

    http://do-it-for-me.apps.yoolk.com/ (in dev: http://do-it-for-me.apps.yoolk.dev/)
    http://product-catalog.apps.yoolk.com/ (in dev: http://product-catalog.apps.yoolk.dev/)
    http://qrcode.apps.yoolk.com/ (in dev: http://qrcode.apps.yoolk.com/)

## Questions?

Please ask any member of the Yoolk Core Team

(c) 2012 Yoolk. All rights reserved.