- Create `~/.datagov_vault_pass.txt` file, containing vault secret.

- Add your AWS credentials (https://www.packer.io/docs/builders/amazon.html)

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
    - via Packer 
        - Define PACKER_BASE_AMI (ex. export PACKER_BASE_AMI=ami-2d39803a)
        - `packer build packer.json`
    
    - via Ansible Playbook to Amazon Dev instance
        - `ansible-playbook datagov-web.yml -i inventories/amazon.dev`
    - or
        - `ansible-playbook datagov-web.yml -i inventories/amazon.vsl4`

- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t datagov/wp .`
    - `docker-compose up -d`
    - Get fresh sql dump of Data.gov WordPress
    - `mysql -P 3333 -u datagov -h 127.0.0.1 -psuperpassword datagov < datagov.sql`
    - `ansible-playbook datagov-web.yml -i inventories/local.dev`
    - Open [http://localhost:8000/](http://localhost:8000/) 
    , default `admin` password is `password`, SAML is disalbed on local 