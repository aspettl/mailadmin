// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import mrujs from "mrujs";

mrujs.start();

// Prefer text/html (instead of the default "*/*") so that Devise will perform proper redirects
mrujs.registerMimeTypes(
  [
    {shortcut: "any", header: "text/html, */*"}
  ]
)
