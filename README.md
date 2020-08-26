BIOS 611 Project 1
==================

Unintentional Poisoning
-----------------------

This repo will eventually contain an analysis of The Global Health Observatory's report on the mortality rate attributed to unintentional poisoning in 183 countries over a 16 year span.

Using This Project
------------------

You will need Docker, and you will need be able to run docker as your user.
    > docker build . -t project1_env
    > docker run -v `pwd`:/home/rstudio -p 8787:8787 -e PASSWORD=<yourpassword> -t project1_env
