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

### Add quarto extension

```         
quarto add quarto-ext/shinylive
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
