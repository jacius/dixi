Dixi
====

Dixi = Docs + Wiki
------------------

Dixi is a wiki app designed for creating and maintaining Ruby software
documentation (especially library API docs) collaboratively. It is
powered by Ruby, Sinatra, and Git (via Grit).

Dixi is still in early development (as of December 2009), so don't
expect anything fancy yet. If you want to help make Dixi the most
kickass documentation system ever, please email jacius+dixi at
gmail.com or send a message to jacius on github.

You can see and play with a live instance of Dixi at
[http://dixi.jacius.info/](http://dixi.jacius.info/)


Why should I use Dixi?
----------------------

* Because automatic doc generators like RDoc can't handle run-time
  definitions or other metaprogramming techniques used in Ruby.

* Because embedding your main documentation in your source code makes
  it really inconvenient for anyone else to contribute to the docs.

* Because static docs don't allow users to ask questions, make
  comments, submit corrections, or provide examples.

* Because regular wikis aren't well-suited for organizing API docs.


Who should NOT use Dixi?
------------------------

* Developers who want to frustrate and alienate their users by
  providing crappy, useless documentation.

* Developers who think a few scattered comments in the source code of
  their huge, complex application counts as "technical documentation".

* Developers who love to maintain documentation all by themselves,
  with no help from anyone else.


FAQ
---

### Can I import my existing docs to Dixi?

There will eventually be a companion script to import RI or YARD
documentation to Dixi. For now, you must copy them to Dixi yourself.

### Can I export docs from Dixi back into my project?

Not currently. There will eventually be a way to export docs as HTML,
RI, YARD, or stub code with RDoc-style documentation comments.

There are no plans to offer a tool to re-embed the docs back into your
real code as comments. The whole point of Dixi is that your docs
*shouldn't* be embedded in your code.


Install
-------

You will need:

* Ruby 1.8.6+ or JRuby 1.4+
* Sinatra 0.94
* Mustache 0.5.0
* Grit 2.0.0
* Kramdown 0.2.0
* Shotgun 0.4 (optional, for development mode)

So...

    gem install sinatra mustache grit kramdown shotgun

There is nothing to install for Dixi itself. Just run it.


Usage
-----

### Development mode

Run `rake shotgun`, then point your browser to
[http://localhost:4567/](http://localhost:4567/)

But it's more interesting to go to, for example, [http://localhost:4567/mylibrary/1.0/Foo](http://localhost:4567/mylibrary/1.0/Foo)

### Production mode

Dixi works well (for me) with Phusion Passenger. Follow the normal
procedures for setting up a Rack app on your host.

### Deploying with Capistrano

Run `rake capconfig` to generate a capconfig.yaml file, then edit it
to provide your deployment details (user name, host, etc.).

Then deploy as usual for Capistrano (`cap deploy:setup` before the first
time, then `cap deploy` to deploy).


License
-------

Copyright 2009 John Croisant

Dixi is licensed under the Apache License, Version 2.0.
See LICENSE.txt and NOTICE.txt for details.


Author
------

John Croisant  <jacius+dixi@gmail.com>
