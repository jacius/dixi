Dixi
====

Dixi = Docs + Wiki
------------------

Dixi is a wiki app specifically designed for maintaining software
documentation collaboratively. It is powered by Ruby, Sinatra, and
Git.

Dixi is still in early development, so don't expect much at the
moment. If you want to help, please email jacius+dixi at gmail.com
or send a message to jacius on github.


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

For development mode, do:

    rake shotgun

    # or, if you don't have rake:

    shotgun -p 4567 config.ru

Then point your browser to [http://localhost:4567/](http://localhost:4567/)

But it's more fun to go to, for example, [http://localhost:4567/mylibrary/1.0/Foo](http://localhost:4567/mylibrary/1.0/Foo)

For production mode... there is no production mode yet.


License
-------

Copyright 2009 John Croisant

Dixi is licensed under the Apache License, Version 2.0.
See LICENSE.txt and NOTICE.txt for details.


Author
------

John Croisant  <jacius+dixi@gmail.com>
