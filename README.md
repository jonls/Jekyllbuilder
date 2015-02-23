Jekyllbuilder Dockerfile
========================

This repository contains a daemon that will continuously listen for
Git push events and rebuild a **[Jekyll](http://jekyllrb.com/)** site
whenever the corresponding Git repository is updated.

The notifications of Git updates are expected to come from messages
through **[RabbitMQ](http://www.rabbitmq.com/)**. These messages can
be generated from a `post-receive` hook in the Git repositories. I am
using [Gitolite](http://gitolite.com) which allows one to define a
default `post-receive` hook. See [post-receive](post-receive) for an
example.

When an update to the Git repository is detected it is cloned and
Jekyll is used to generate the final site. The clone is done from
a local repository in `/git`. The final site is generated in `/www`.

Usage
-----

```
$ docker run -d --link rabbitmq:rabbitmq \
      -e "JEKYLL_REPO=<jekyll-website-repo-name>" \
      -v <www-dest>:/www \
      -v <local-git-repos>:/git:ro \
      jonls/jekyllbuilder
```

The `rabbitmq` would be another container running RabbitMQ with the port
5672 exposed. A prebuilt `rabbitmq` container can be found in the [Docker
Hub Registry](https://registry.hub.docker.com/_/rabbitmq/).

ToDo
----

- Listen for multiple Git repositories
- Specify destination for each build
- Specify Git branch to build
- Optionally clone public remote repository instead of local
