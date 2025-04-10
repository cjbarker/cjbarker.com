# cjbarker.com

Personal website via customize [hugo](https://gohugo.io/getting-started/usage/) theme 'cjb' for generating and serving http://cjbarker.com

## Drafting Blog Article
```
hugo new blog/my-new-post.md
```

## Testing
```bash
hugo server --bind 0.0.0.0 --port 8000 --buildFuture --logLevel debug
hugo server --bind 0.0.0.0 --port 8000 --buildFuture --verbose
```
Access server locally with support of LiveReload request debug enabled: [http://localhost:8000/?debug=LR-verbose](http://localhost:8000/?debug=LR-verbose)


## Deployment
Build the static site via Hugo, which will create directory 'public' for copying contents to hosting endpoint.

```bash
hugo
./deploy.sh
```
