
These are working notes about the structure and formatting of Dixi
resource contents.


Formatting
==========

YAML + Kramdown
---------------
    
Contents are stored as a YAML mapping. Text fields (such as synopsis
and details) are parsed as kramdown, a backwards mostly-compatible
variant of Markdown.

Internal Links
--------------

As a special Dixi-specific extension to the kramdown syntax, items in
[[double square brackets]] are parsed as special links to other pages
in the wiki. This syntax is intended to be similar to Mediawiki's
internal links syntax. These links are evaluated and converted to
Markdown-style links before the text is handed off to kramdown for
conversion to HTML.

The link destination is evaluated according to the namespace of the
resource they are used in. For example, within the Rubygame::Screen
class page, the `[[.new]]` creates a link to the Rubygame::Screen.new
class method page, while `[[Surface]]` creates a link to the
Rubygame::Surface class (because Screen and Surface are siblings in
the Rubygame namespace).

The rules for link destinations are:

* `[[::Full::Path::To::Klass]]` :
  Link to a specific class/module. If that class/module doesn't exist
  yet, the link is styled with the ".newpage" HTML class, and points
  to the page to create that resource.

* `[[Klass]]` :
  Ambiguous link to a class/module. Dixi tries to guess what
  class/module you meant according to these rules:

  1. If there is a class/module of that name in the top namespace,
     link to that.
  2. Else, if there is a class/module of that name in the current
     namespace (i.e. defined under the current module or class), link
     to that.
  3. Else, if there is a class/module of that name which is a sibling
     to the current namespace (same parent namespace), link to that.
  4. Else, Dixi does a breadth-first search for a class/module of that
     name anywhere in the current library.
  5. Finally, none of the above rules matched, the link is rendered
     as plain text span (not a link) with a ".deadlink" HTML class.

  The same rules are applied to partial paths. E.g.
  `[[Events::KeyPressed]]` could match `Rubygame::Events::KeyPressed`,
  but would not match (toplevel) `KeyPressed` or `Rubygame::KeyPressed`.
  
* `[[Klass.cmethod]]` :
  A link to a class method in that class/module.

* `[[Klass#imethod]]` :
  A link to a instance method in that class/module.

* `[[.cmethod]]` :
  A link to a class method in the current class/module.

* `[[#imethod]]` :
  A link to an instance method in the current class/module.

* `[[library:linkpath]]` :
  Link to something in the current version of another library in the
  same Dixi site. Note that there is only one `:`. You may optionally
  put a one or more spaces before and/or after the `:`, for readability.
  E.g. `[[library : linkpath]]`

* `[[library/version:linkpath]]` :
  Link to something in a specific version of another library in the
  same Dixi site.

There are also special forms that affect how the link is formatted.

* `[[linkpath|custom text]]` :
  A link to "linkpath" that renders as "custom text" instead of
  "linkpath". E.g. `[[Rubygame::Surface#blit|the Surface class's #blit
  method]]` You may optionally put one or more spaces before and/or
  after the `|`, for readability. E.g. `[[linkpath | custom text]]`

* `[[linkpath]]suffix` :
  A link to "linkpath" that renders as "linkpathsuffix". Useful for
  plural forms. "suffix" can be any string of one or more letters
  (including international letters). Not valid for links with custom
  text. (You should add the suffix in the custom text in that case)

    
Classes
=======

Class information is represented in a structure like this:

    type: class
    name: Rubygame::Screen
    base: Rubygame::Surface
    includes: []
    constants: []
    cmethods:
      - Rubygame::Screen.new
      - Rubygame::Screen.close
    imethods:
      # notice blit is a Surface method, indicating inheritance
      - Rubygame::Surface#blit
      - Rubygame::Screen#flip
    synopsis:
      Screen represents the display window for the game. It is a
      special kind of [[Surface]] that is displayed to the user.
    details: |
      Screen represents the display window for the game. It is a
      special kind of [[Surface]] that is displayed to the user.

      Screen inherits most of the Surface methods, and can be passed
      to methods which expect a Surface, including [[Surface#blit]].
      However, the Screen cannot have an alpha channel or a colorkey,
      so [[Surface#alpha=]], [[Surface#set_alpha]],
      [[Surface#colorkey=]], and [[Surface#set_colorkey]] are not
      inherited.

      Please note that only one Screen can exist at a time, per
      application; this is a limitation of SDL. Use [[.new]] (or
      its alias, [[.open]]) to create or modify the Screen.

      Also note that no changes to the Screen will be seen until it is
      refreshed. See [[#update]], [[#update_rects]], and [[#flip]] for
      ways to refresh all or part of the Screen.
    

Modules
=======

Same format as classes, except "type" is "module", and "base" is
ignored.


Class Methods
=============
    
    type: class method
    name: Rubygame::Screen.new
    base: Rubygame::Surface.new
    args:
      - name: size
        info: Requested window size (in pixels), in the form [width,height]
        type: Array of 2 integers
      - name: depth
        info: Requested color depth (in bits per pixel).
              If 0 (default), uses the current system color depth. 
        type: Integer (usually 0, 8, 16, or 32)
        default: 0
      - name: flags
        info: An array of integer flags (see method description),
              or an integer of the flags combined with (`|`).
        type: Array of integers, or an integer.
        default: [Rubygame::SWSURFACE]
    aliases:
      - Rubygame::Screen.open
    synopsis:
      Create a new Rubygame window if there is none,
      or modify the existing one.
    details: |
      Create a new Rubygame window if there is none, or modify the
      existing one. You cannot create more than one Screen; the
      existing one will be replaced. (This is a limitation of SDL.)

      Returns the resulting Screen.

      flags
        : an Array of zero or more of the following flags.

          * [[Rubygame::SWSURFACE]]: Create the video surface in
            system memory.
          * [[Rubygame::HWSURFACE]]: Create the video surface in video
            memory.
          * etc.


Module Methods
==============

Same format as class methods, except "type" is "module method".


Instance Methods
================

Same format as class methods, except "type" is "instance method" and
name uses "#" instead of "." to separate the class/module from the
method name.
