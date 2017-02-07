- Create `~/.dashboard_vault_pass.txt` file, containing vault secret.

- Add your AWS credentials (https://www.packer.io/docs/builders/amazon.html)

    For example, `~/.aws/credentials` can contain: 

    ```
    aws_access_key_id=*** 
    aws_secret_access_key=**
    ```
    
- Load ansible galaxy roles

     `ansible-galaxy install -r requirements.yml`

- Run playbook
    - via Packer 
        - Define PACKER_BASE_AMI (ex. export PACKER_BASE_AMI=ami-2d39803a)
        - `packer build packer.json`
    
    - via Ansible Playbook
        - `ansible-playbook dashboard-web.yml -i inventories/amazon.dev`
    - or
        - `ansible-playbook dashboard-web.yml -i inventories/amazon.vsl4`
         
- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t pod/dashboard .`
    - `docker-compose up -d`
    - `ansible-playbook dashboard-web.yml -i inventories/local/hosts --tags "provision" --skip-tags "secops,trendmicro"`
    - `ansible-playbook dashboard-web.yml -i inventories/local/hosts --tags "deploy"`

    - Open [http://localhost:8088/](http://localhost:8088/)