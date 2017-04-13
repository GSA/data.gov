- Create `~/.datagov_vault_pass.txt` file, containing vault secret.

- Add your AWS credentials

    For example, `~/.aws/credentials` can contain: 

    ```
    aws_access_key_id=*** 
    aws_secret_access_key=**
    ```

- Make sure you have access to all Data.gov github repositories (including private)
and check that your github ssh key is ready for AgentForwarding 
(https://developer.github.com/guides/using-ssh-agent-forwarding/)

- Load ansible galaxy roles

     `ansible-galaxy install -r requirements.yml`

- Run playbook
    - via Ansible Playbook to Amazon Dev instance
        - `ansible-playbook datagov-web.yml -i inventories/amazon.dev`
    - or
        - `ansible-playbook datagov-web.yml -i inventories/amazon.vsl4`

- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t datagov/wp .`
    - `docker-compose up -d`
    - Get fresh sql dump of Data.gov WordPress
    - `mysql -P 3000 -u datagov -h 127.0.0.1 -psuperpassword datagov < datagov.sql`
    - `cd ../../..`
    - `ansible-playbook datagov-web.yml -i inventories/local/hosts --tags provision --skip secops,trendmicro,postfix`
    - Open [http://localhost:8000/](http://localhost:8000/) 
    , default `admin` password is `password`, SAML is disalbed on local 