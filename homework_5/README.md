homework 5
===========

You will need to build the docker container as specified in the project README.md. Then to run **homework_5.Rmd**, run the rstudio server using:
> docker run -v $(pwd):/home/rstudio -p 8787:8787 -e PASSWORD=yourpassword -t project1_env

and connect your machine to port 8787

Part of the homework uses Python. To run **homework_5_python.py** in a jupyter notebook,
run:
> docker run -p 8765:8765 -v `pwd`:/home/rstudio -e PASSWORD=$SECRET_PWD -it project1_env sudo -H -u rstudio /bin/bash -c "cd ~/; jupyter lab --ip 0.0.0.0 --port 8765"

and follow the instructions presented.

All scripts and files for this assignment are in the homework_5 directory.
