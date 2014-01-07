# dockerize

A bash utility aimed at helping to integrate docker with the build process.

## credit
This is a fork of the [cambridge healthcare project]
(https://github.com/cambridge-healthcare/dockerize).  It's my experimental
version which I'm using to mess around with docker.

See the original project for a good outline of what this does and read their
excellent blog post [Continuous Delivery with Docker and Jenkins - part II]
(http://blog.howareyou.com/post/65048170054/continuous-delivery-with-docker-and-jenkins-part-ii)
which is what got me looking into this stuff to start off with.

## differences
The main differences with the original are:

### git subcommand
The git sub-command replaces the github sub command to allow this to work with
any git repo (primarily as I spend my working life on projects which don't
live on github).

### test subommand
This is similar to the boot subcommand except it is targetted at running tests.
It requires that the containter will run it's tests when executed with the
command `--run-tests`.  See [sinatra_docker_test]
(https://github.com/roovo/sinatra_docker_test) for an example.

### dependent containters
This functionality is currently missing - need to find the time to experiment
first.

### branches
Branches are specified in the boot and test sub-commands using a command line option
`-b|--branch`.
