#!/bin/bash

docker exec -it gitlab gitlab-rake gitlab:backup:restore
