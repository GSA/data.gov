.PHONY: apply clean plan ssh

clean:
	rm plan.tfplan

plan:
	terraform plan -out plan.tfplan

apply:
	terraform apply plan.tfplan

jumpbox:
	ssh -A -l ubuntu $(shell terraform output | grep jumpbox_ip | cut -d = -f 2)
