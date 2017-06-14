         
- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t pod/dashboard .`
    - `docker-compose up -d`
    - `ansible-playbook dashboard-web.yml -i inventories/local/hosts --tags provision --skip-tags prod`
    - `ansible-playbook dashboard-web.yml -i inventories/local/hosts --tags deploy --skip-tags prod`

    - Open [http://localhost:8008/](http://localhost:8008/)