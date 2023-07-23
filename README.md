# cjbarker.com

Personal website via customize [hugo](https://gohugo.io/getting-started/usage/) theme 'cjb' for generating and serving http://cjbarker.com

## Drafting Blog Article
```
hugo new blog/my-new-post.md
```

## Testing
```bash
hugo server --bind 0.0.0.0 --port 8000 --buildFuture --log --logFile port800log
hugo server --bind 0.0.0.0 --port 8000 --buildFuture --verbose
```

## Deployment
Build the static site via Hugo, which will create directory 'public' for copying contents to hosting endpoint.

```bash
hugo
./deploy.sh
```
