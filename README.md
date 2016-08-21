# wsgame

A *very* simple app, pretty much solely an exercise on Rails 5-flavoured WebSockets. It's being created as an overdue university assignment so don't expect any fireworks let alone specs. It's probably going to be a rendition of a board game, but which one? I haven't decided yet. Gah, If I'm lazy enough it might well end up as a tic-tac-toe.

# Requirements

* Ruby 2.3.1
* Rails 5
* Redis (production only)
* PostgreSQL

# Running

Get RVM from http://rvm.io/, `gem install bundler` then `bundle install`, create a `config/database.yml` file for your PostgreSQL configuration (will post a sample when I'm less lazy), then `rake db:setup db:seed` and start the server with `rails s` - there you go, at least I think that's enough.

# Accolades

_Heavily_ inspired and influenced by www.kurnik.pl.
