# Roc HTML

A library to create HTML in Roc.

## Example

This Roc code:

```roc
Html.html [] [
    Html.body [] [
        Html.h1 [] [Html.text "Roc"],
        Html.p [] [
            Html.text "You should really check out ",
            Html.a [Attribute.href "https://roc-lang.org/"] [Html.text "Roc"],
            Html.text "!",
        ]
    ]
] |> Html.render
```

Returns this HTML (give or take a little formatting):

```html
<!doctype html>
<html>
  <body>
    <h1>Roc</h1>
    <p>You should really check out <a href="https://roc-lang.org/">Roc</a>!</p>
  </body>
</html>
```

## Licence

This repository is released under the [UPL licence](./LICENCE) and was mostly written by [Brian Carroll](https://github.com/brian-carroll/). Thanks, Brian!
