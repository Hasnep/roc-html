app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    html: "../src/main.roc",
}

import cli.Stdout
import html.Html
import html.Attribute

main =
    page = Html.html [] [
        Html.body [] [
            Html.h1 [] [Html.text "Roc"],
            Html.p [] [
                Html.text "My favourite language is ",
                Html.a [Attribute.href "https://roc-lang.org/"] [Html.text "Roc"],
                Html.text "!",
            ],
        ],
    ]
    renderedHtml = Html.render page
    Stdout.line renderedHtml
