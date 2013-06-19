# Axilla

Simple Node.js view templating using [handlebars](http://handlebarsjs.com/).

Install with `npm install axilla`

```javascript
var axilla = require('axilla');
```

Features
  * Synchronous interface
  * Intuitive API
  * Template Caching

### Example

Give the following directory structure
```
* /Users/ben/projects/example/
  * components/
    * users/
      * _form.html.mustache
      * index.html.mustache
      * new.html.mustache
      * edit.html.mustache
      * show.html.mustache
    * todos/
      * _widget.html.mustache
      * index.html.mustache
      * show.html.mustache
  * public/
    * templates/
      * one_off_template.html.mustache
```

Axilla first needs to be configured with the location of any/all templates.
```javascript
var baseDir = "/Users/ben/projects/example/components";
axilla.configure(baseDir, function(err){
  // handle error if err == null
  // has now stored a reference to all files ending in .mustache in /components
});
```

Axilla can be configured multiple times with different locations of templates.
```javascript
var secondBaseDir = "/Users/ben/projects/example/public";
axilla.configure(secondBaseDir, function(err){
  // handle error if err == null
  // has now stored a reference to all files ending in .mustache in /public
});
```

This will find all templates ending in `.mustache` at any depth in `/Users/ben/projects/example/public` and `/Users/ben/projects/example/components`. Axilla will store files that are prefixed with an underscore as partials for use within other views. Inside of the mustache template, they can be referenced with the `partial` helper:

```html
{{partial "users/form"}}
```

When referencing a partial filename in a view does not include the underscore.

To render a template, call `axilla.render` passing the path and filename (minus the extensions) relative to the directory supplied to `axilla.configure`, i.e.

```javascript
var indexHtml = axilla.render('users/index', {users: []});
var showHtml = axilla.render('todos/show', {todo: {}});
var oneOffHtml = axilla.render('templates/one_off_template', {});
```

## API

