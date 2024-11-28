default: format check test examples docs

format:
    roc format src/
    roc format examples/

check:
    roc check src/main.roc
    fd --extension roc . examples/ --exec roc check

test:
    roc test src/main.roc

examples:
    fd --extension roc . examples/ --exec roc run

docs:
    roc docs src/main.roc
