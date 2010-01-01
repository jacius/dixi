Dixi Under the Hood
===================

Dixi is built on top of Sinatra and Git. Instead of using a
traditional database, content is stored as YAML files in a Git
repository.


Why the unconventional system?
------------------------------

* Databases make setup and maintenance more difficult and time
  consuming. 

* Not using a database gives Dixi more agility. There are no
  migrations to apply, columns and tables to manage, etc.

* Git provides fast and easy revision control and content backup.
  Off-site data backups are just a "git pull" away.

* It's easy to process or edit the YAML files by hand or by script if
  desired. You can even modify them locally and then merge the changes
  into the production repository when you're done.


Glossary
--------

The following terms are used in this document, and throughout Dixi:

Resource
  : A document that users can read, create, and edit. API entries,
    tutorials, comments, etc.

Parent (resource, class, module, or method)
  : The resource which contains another resource. For example, a
    method's parent is the class or module to which it belongs.

Child (resource, class, module, or method)
  : The inverse of parent. A method is the child of the class or
    module to which it belongs.

Base (resource, class, module, or method)
  : The resource from which this is derived. A resource inherits
    properties from its base resource. For classes, base means the
    superclass. For methods, it means the super method. The definiton is
    more fuzzy for modules, but one example would be a module which is
    intended as a replacement for another module.

    Note that classes and modules also have the separate concept of
    included modules. Properties from included modules are also
    inherited. Use whichever way best describes the relationship
    between resources.

Revision
  : A modification to a resource, stored in the Git repository. Also
    known as a commit, edit, or changeset.

Project
  : The software being documented (e.g. "Rubygame").

Version
  : A specific version of the project (e.g. "2.6").


API data directory structure
----------------------------

API docs are stored in a hierarchical directory structure that mimics
the hierarchy of modules, classes, and methods in the project's code.
In general:

  contents/{project}/{version}/api/{api_path}-{type_suffix}.yaml

For example, the documentation for Rubygame::Surface#blit in Rubygame
2.6.2 would be stored at:

  contents/rubygame/2.6.2/api/Rubygame/Surface/blit-im.yaml

Documentation for the Rubygame::Surface class itself would be at:

  contents/rubygame/2.6.2/api/Rubygame/Surface-c.yaml

The possible type suffixes are:

* m  (module) 
* c  (class)
* mm (module method)
* cm (class method)
* im (instance method)

Punctuation in method names is preserved in the filename. So, a class
method "open?" would have the filename "open?-cm.yaml". An instance
method "-" would be "--im.yaml". However some puncuation will be
escaped in URIs. See the section below.


Web Interface
-------------

Resource URIs resembles the "contents" directory structure.

Assuming the root URI of the Dixi site is "http://dixi.foo/", the
URI for the Rubygame::Surface class in Rubygame 2.6.2 would be:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface

Note that it is NOT "Rubygame-m" or "Surface-c". For modules and
classes, the type suffix is omitted from the URI. You can't have have
a module and a class with the same name, so no type is necessary to
unambiguously identify the resource.

For methods, the situation is different, because it's possible to have
multiple methods with the same name, but different types (module,
class, or instance).

The canonical URI for Rubygame::Surface#blit in Rubygame 2.6.2 would
be:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface/blit-im

However, if there is only one method of that name, the following URI
is encouraged, and is used by Dixi when generating links to read the
resource (but not links to edit the resource):

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface/blit

If there are multiple methods with the same name, visiting that URI
will display a disambiguation page, listing the synopses of the
methods and offering links to the URIs with type suffixes.

For editing operations (e.g. creating, updating, and deleting), and
for accessing the resource as YAML, the typed URI should always be
used.


### Punctuation in URIs

The following punctuation characters should be escaped in URIs when
used literally as part of a method name:

* "%" should be "%25"
* "?" should be "%3F"
* "+" should be "%2B"

As a user convenience, Dixi will redirect the user to the correct URI
if it detects that those puncuation marks were probably meant literally.
For example, visiting this URI:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Screen/open?

Will redirect the user to the correct URI:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Screen/open%3F

Dixi does not do this kind of redirection for editing operations or
for acessing the resource as YAML, so the punctuation must be properly
escaped in those cases.


YAML Interface
------------------

### GET (reading a resource)

API resources are also served as YAML files, by adding ".yaml" to the
URI:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface/blit-im.yaml

Punctuation must be properly escaped in the URI, as mentioned above.
For example, the following URI is invalid:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Screen/open?-cm.yaml

It should be:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Screen/open%3F-cm.yaml

The "typed" URI should always be used. However, Dixi may perform
redirection in unambiguous cases. For example:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface.yaml

Will redirect to the correct URI:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface-c.yaml

If an untyped request is ambiguous (such as when there are multiple
methods with the name same), Dixi will serve a YAML-formatted error
message containing proper URIs to the possible resources.


### PUT (creating or updating a specific resource)

In addition to GET (as decribed above), Dixi supports the HTTP PUT,
POST, and DELETE methods for YAML files, to allow creating and
accessing Dixi via many different types of software.

PUT is used to create or update a resource at a specific address. It
is valid for modules, classes, and methods (and other resource types,
when they are implemented). For example, to create or update the
Surface class, you could PUT some YAML data (in the format described
in format.markdown) to this URI:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface-c.yaml

If your YAML data includes a resource type, it is also permissible to
PUT to an untyped URI, such as:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface.yaml

If the YAML data does not include a resource type, or if the type is a
class and there is an existing module by that name (or vice versa),
the PUT will fail and return a YAML-formatted message structure
indicating the error.

If the request succeeds, Dixi will serve a YAML-formatted success
message containing the URI for the created/updated resource.


### POST (creating or updating a child resource)

POST is used to create or update a resource under a parent resource.
The POST request is sent to the parent resource's URI, but results in
creating a child resource.

Note: POST is discouraged for creating API entries; you should use PUT
instead, as described above. But you could create POST the YAML data
for a method to this URI to add that method to the Surface class:

  http://dixi.foo/rubygame/2.6.2/api/Rubygame/Surface.yaml

If the request succeeds, Dixi will serve a YAML-formatted success
message containing the URI for the created/updated resource.


### DELETE (deleting a resource and its children)

If you send a DELETE method to a resource's URI, that resource and all
its children will be deleted.

If the request succeeds, Dixi will serve a YAML-formatted success
message containing the URIs of all the resources (including children)
that were deleted.


Inheritance from earlier versions
---------------------------------

Each version implicitly inherits content from earlier versions, unless
that content is overridden in the new version. For example, consider
three versions of a library with the following content:

* 1.0:
** Foo.yaml
* 2.0:
** Bar.yaml
** Bar/Baz.yaml
* 3.0:
** Foo.yaml

In this setup, version 1.0 has "Foo" docs only. Version 2.0 has "Bar"
and "Bar/Baz" docs, and also inherits version 1.0's "Foo" docs.
Version 3.0 inherits version 2.0's "Bar" and "Bar/Baz" docs, but
overrides version 1.0's "Foo" docs with a new definition.


Auxillary content
---

### Comments

To be written.

### Articles (Tutorials/Guides)

To be written.
