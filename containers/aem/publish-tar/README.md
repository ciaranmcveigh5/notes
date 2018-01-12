# AEM 6.X Publish image

This is based on examples 
* https://github.com/AdobeAtAdobe/aem_6-1_docker
* https://github.com/sergeimuller/aem-base
* https://hub.docker.com/u/ggotti/

For standalone usage run this command to build image

```
docker build -t project_aem-publish .
```

run the image with this command

```
docker run --name AEM_PUBLISH -p 4503:4503 -d project_aem-publish
```

The AEM quickstart configuration is in the resources directory.  If you need to change JVM options or other parameters you can do it in that file and rebuild the image.