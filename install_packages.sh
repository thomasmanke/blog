#!/bin/bash

# install extensions and packages that cannot be
# controlled with micromamba and env.yml

# add quarto extension shinylive
quarto add --no-prompt quarto-ext/shinylive

# add R-package shinylive
Rscript -e 'pak::pak("posit-dev/r-shinylive")'