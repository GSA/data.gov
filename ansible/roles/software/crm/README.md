         
- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t gsa/crm .`
    - `docker-compose up -d`
    - Get fresh sql dump of crm
    - `mysql -P 3377 -u crm -h 127.0.0.1 -psuperpassword crm < ~/Desktop/prod.crm.sql`
    - `cd ../../..`
    - `ansible-playbook crm-web.yml -i inventories/local/hosts --tags provision --skip-tags prod`
    - Open http://localhost:8888/
    
    - PHPMyadmin : `docker run --name myadmin -d -e PMA_HOST=docker.for.mac.localhost -e PMA_PORT=3377 -e PMA_USER=crm -e PMA_PASSWORD=superpassword -p 8997:80 phpmyadmin/phpmyadmin`
