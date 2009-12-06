Dixi
====

Dixi = Docs + Wiki
------------------

Dixi is a wiki app specifically designed for maintaining software Ruby
library documentation collaboratively. It's powered by Ruby, Sinatra
and Git.

Dixi is still in pre-alpha development, so don't expect much at the
moment. Collaborators are *very* welcome.


Install
-------

You will need:

* Ruby 1.9
* Sinatra 0.94
* Mustache 0.5.0
* Grit 2.0.0
* Shotgun 0.4 (optional, for development mode)

So...

    gem install sinatra mustache grit shotgun

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

I haven't decided yet. So, all rights reserved, for now.


Author
------

John Croisant  <jacius@gmail.com>
