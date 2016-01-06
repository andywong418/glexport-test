glexport-test
=============

**glexport-test** is the backend focused take home interview project for Flexport Engineering. The Flexport backend is written in Ruby on Rails, and while its influence is obvious, this project is designed to be framework agnostic.

Given a database with already seeded tables and data, please create a `GET index` endpoint `/api/v1/shipments` according to the specification as described in `api/v1/shipments_spec.rb`

Instructions
------------

1. Read the rest of this README and review `api/v1/shipments_spec.rb` to understand the endpoint requirements
2. Create your sample application, using the database dump `glexport_development`
3. Perform the following one time setup steps to get the spec runner working
  1. Navigate to the project root
  2. Modify `spec/config.rb` if necessary
  3. Install ruby if necessary
  4. Install the `bundler` gem if necessary
  5. Run `bundle install`
  6. Make sure your application server is running
4. Run `bundle exec rspec` until specs pass

What we're looking for
----------------------