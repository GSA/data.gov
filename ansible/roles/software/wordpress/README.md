
- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t datagov/wp .`
    - `docker-compose up -d`
    - Get fresh sql dump of Data.gov WordPress
    - `mysql -P 3333 -u datagov -h 127.0.0.1 -psuperpassword datagov < datagov.sql`
    - `cd ../../..`
    - `ansible-playbook datagov-web.yml -i inventories/local/hosts --tags provision --skip secops,trendmicro,postfix`
    - Open [http://localhost:8000/](http://localhost:8000/) 
    , default `admin` password is `password`, SAML is disalbed on local 