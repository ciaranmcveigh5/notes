# AEM 6.X Author image

This is based on examples 
* https://github.com/AdobeAtAdobe/aem_6-1_docker
* https://github.com/sergeimuller/aem-base
* https://hub.docker.com/u/ggotti/

For standalone usage run this command to build image

```
docker build -t project_aem-author .
```

run the image with this command

```
docker run --name AEM_AUTHOR -p 4502:4502 -d project_aem-author
```

The AEM quickstart configuration is in the resources directory.  If you need to change JVM options or other parameters you can do it in that file and rebuild the image.