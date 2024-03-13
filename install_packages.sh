#!/bin/bash

# install extensions and packages that cannot be
# controlled with micromamba and env.yml

# add quarto extension shinylive
quarto add --no-prompt quarto-ext/shinylive

# add quarto extension include-code-files
quarto add --no-prompt quarto-ext/include-code-files

# add R-package shinylive
Rscript -e 'pak::pak("posit-dev/r-shinylive")'

#Rscript -e "install.packages('deSolve')"
Rscript -e "install.packages('deSolve', repos='http://cran.us.r-project.org', dependencies=TRUE)"