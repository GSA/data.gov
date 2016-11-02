- Create `~/.crm_vault_pass.txt` file, containing vault secret.

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
        
        - `packer build packer.json`
    
    - via Ansible Playbook
        - `ansible-playbook crm-web.yml -i inventories/amazon.dev`
    - or
        - `ansible-playbook crm-web.yml -i inventories/amazon.vsl4`
         
- Development with [Docker for Mac](https://www.docker.com/products/docker)
    - `cp ~/.ssh/id_rsa.pub authorized_keys`
    - `docker build -t gsa/crm .`
    - `docker-compose up -d`
    - `ansible-playbook crm-web.yml -i inventories/local.dev`
    - Open http://localhost:8888/