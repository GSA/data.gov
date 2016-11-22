The application can host multiple jekyll sites, a webhook call will trigger jekyll to rebuild site from github repo, and optionally push code to AWS S3.

To install jekyll apps on to remote machine:

- `ansible-galaxy install -f -p ansible/roles/software/jekyll/vendor -r ansible/roles/software/jekyll/requirements.yml`

- `ansible-playbook ansible/jekyll.yml -i /path/to/hosts`

To add/config apps, edit jekyll_apps in `ansible/jekyll.yml`, for example:

```
      - {
          name: "sdg-indicators",
          repo: "https://github.com/GSA/sdg-indicators/",
          config: "_config_prod.yml",
          branch: "master",
          port: 8000,
          s3_bucket: "{{ s3_bucket_sdg }}",
          secret_key: "{{ jekyll_webhook_secret }}"
        }
```

- `port` is for internal webrick listenning port. keep it unique from other apps.
- `s3_bucket` is optional. If provided, the code will be pushed to the bucket each time jekyll files are rebuilt.
- `secret_key` is the secret for the webhook url.


A call to the http://remote-machine-ip/webhook/[name]/[secret_key] will trigger the jekyll rebuild. HTTPS protocol is recommended to protect the secret_key.

By default, the app is reading EC2 IAM role info to be authenticated to push code to s3. Or, optionally, the aws key and cert pair can been added into /root/.s3cfg.
