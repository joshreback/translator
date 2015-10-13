# Translating Applications Using Key-Value Back Ends

Goal is to create a Rails application that stores translations in a backend that isn't a YAML file.

Advantage is that servers can all receive the most up to date translations without having to keep the YAML files in sync.

Disadvantage is using a database rather than an in-memory hash has a huge performance hit.

Resolved to store translations in a Redis store.

### Revisiting `Rails::Application`

- A rails application inherits from a rails engine!
- Meaning it can do all the things an engine does, plus:
  - bootstrapping (i.e, setting up logger and load paths)
  - has its own router and middleware stack
  - load and initialize its own plug-ins
  - reloading code and routes between requests
  - loading tasks and generators when appropriate
- For tasks that need the application to be initialized, you must depend on the `:environment` task which initializes the application
  - Other basic rake tasks run quickly since they define, but do not initialize, the application
- The Rails router exposes a few methods, but the main one is `draw()`
  - `routes.draw` is designed to work with code reloading
  - whereas `routes.prepend` or `routes.append` define sticky routes that won't be redrawn
    - (since they typically are in files that won't be reloaded)

### I18n Back Ends and Extensions

- The `I18n.translate()` method call delegates to `I18n.backend()`
- I18n ships with 3 backends:
  - `I18n::Backend::Simple` keeps translations in an in-memory hash populated by YAML files
  - `I18n::Backend::KeyValue` uses a key-value store (this is what we'll use)
    - Required api: a method to read a key, a method to set a value for a key, and a method to retrieve all keys
  - `I18n::Backend::Chain` allows you to chain several backends as fallbacks

- In this chapter, we'll use two custom I18n extensions:
  - `I18n::Backend::KeyValue`
  - `I18n::Backend::Memoize`

### Rails and Sinatra

-