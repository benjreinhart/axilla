# Axilla

Simple Node.js view templating using [handlebars](http://handlebarsjs.com/).

Features
  * Synchronous interface with template caching
  * Flexible API

Install with `npm install axilla`

```javascript
var axilla = require('axilla');
```

### Example

An example app can be found [here](https://github.com/benjreinhart/axilla/tree/master/example/todos) (in the example directory in this repo).

Give the following directory structure
```
* /Users/ben/projects/example/
  * components/
    * users/
      * _form.mustache
      * index.mustache
      * new.mustache
      * edit.mustache
      * show.mustache
    * todos/
      * _widget.mustache
      * index.mustache
      * show.mustache

  * core/
    * layouts/
      * application.mustache
  * public/
    * templates/
      * one_off_template.mustache
```

Axilla first needs to be configured with the location of any/all templates.
```javascript
var baseDir = "/Users/ben/projects/example/components";
axilla.configure(baseDir)
// has now stored a reference to all files ending in .mustache in /components
```

Axilla can be configured multiple times with different locations of templates.
```javascript
var secondBaseDir = "/Users/ben/projects/example/public";
axilla.configure(secondBaseDir);
// has now stored a reference to all files ending in .mustache in /public
```

Templates that are layouts should be specified as such:
```javascript
var layoutPath = "/Users/ben/projects/example/core/layouts";
axilla.configure(layoutPath, {layouts: true});
// has now stored a reference to all files ending in .mustache in /public
```

A default layout should be specified:
```javascript
axilla.setDefaultLayout('application');
```

This will find all templates ending in `.mustache` at any depth in `/Users/ben/projects/example/public`, `/Users/ben/projects/example/components` and `/Users/ben/projects/example/core/layouts`. Axilla will store files that are prefixed with an underscore as partials for use within other views. Inside of the mustache template, they can be referenced with the `partial` helper:

```html
<div class="new-user-form">{{partial "users/form"}}</div>
```

When referencing a partial inside the views, the filename does not include the prefixed underscore.

Within the layouts, the special attribute `yield` represents the template that is being rendered. For example, a layout would look something like the following:

```html
<!-- core/layouts/application.mustache -->
<html>
  <head>
  </head>
  <body>
    <div id="main">
      {{yield}}
    </div>
  </body>
</html>
```

To render a template, call `axilla.render` passing the path and filename (minus the extensions) relative to the directory supplied to `axilla.configure`, i.e.

```javascript
var indexHtml = axilla.render('users/index', {users: []});
var showHtml = axilla.render('todos/show', {todo: {}});
var oneOffHtml = axilla.render('templates/one_off_template', {});
```

We can shorten this by invoking `axilla` with defaults.

```javascript
var render = axilla('users');
var html = render('index', {users: []});
```

## API

### *axilla(pathOrOptions[, options])

Invoking `axilla` and passing either a `path` or `options`, or both, will set those as defaults and return a function scoped with those defaults.

### *axilla.configure(path[, options])*

`path` must be an absolute path to a directory. `options` can contain the following:

* `layouts` - if set to true, templates found at `path` will be treated as layouts and can be referenced later as a layout.
* `cache` - If set to false, templates will be read from disk every time they are rendered. This is a nice feature in development, where templates will be reloaded without having to restart the server. Caching is on by default.

### *axilla.render(path, viewObject[, options])*

This will render the html of the template found at `path` with the values in `viewObject`. `options` may specify a different layout then the default or `false` to render the template without the layout.

### *axilla.setDefaultLayout(path)*

Will set the already configured layout as the default layout.

### *axilla.clearCache()*

Will clear any references to any templates. Most likely not of use, except maybe in testing.

### *axilla.handlebars()*

Will return the reference to the Handlebars library. Useful for those who want to take advantage of Handlebars ability to define helpers.
