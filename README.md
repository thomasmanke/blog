# My Web Site

### Clone Repository

```         
git clone git@github.com:thomasmanke/blog.git
```

### Install/Update dependencies

```         
mamba env create -f env.yml 
mamba env update -f env.yml
```

For Apple M1/M2 (arm64) many package are not yet available.
Use instead:
```
# CONDA_SUBDIR=osx-64 micromamba create -f env.yml
micromamba create -f env_apple.yml
```
### Delete envrionment

```
micromamba remove --name web_apple --all
```

### Add quarto extensions

```         
quarto add quarto-ext/shinylive
quarto add quarto-ext/include-code-files
```

### Add shinylive-R
```
install.packages('devtools')
library(devtools)
install_github("posit-dev/r-shinylive")
```
### Render web site

```         
#https://github.com/quarto-dev/quarto-cli/discussions/3977
export QUARTO_PYTHON=/Users/manke/miniconda3/envs/web/bin/python
quarto render
quarto preview
```

### Publish gh-pages

```
quarto publish gh-pages
```
