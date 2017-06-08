         
- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t gsa/crm .`
    - `docker-compose up -d`
    - `ansible-playbook crm-web.yml -i inventories/local.dev`
    - Open http://localhost:8888/