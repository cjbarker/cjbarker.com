# cjbarker.com

Personal website via customize hugo theme 'cjb' for generating and serving http://cjbarker.com

## Deployment
Build the static site via Hugo, which will create directory 'public' for copying contents to hosting endpoint.

```bash
hugo
```

## Testing
```bash
hugo server --bind 0.0.0.0 --port 8000 --log --logFile port800log
```
