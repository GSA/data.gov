# Infrastructure as Code Practices
## Practices we want to apply	

1. Make the code modular
   1. Avoids the use of long variable names to provide context
   2. Divide the script in multiple segments, which make easier to track and merge changes
   3. Reuse of provisioning code (avoid copy-paste and difficult maintenance)
2. Ensure generated resources are identifiable. It is easy to generate a lot of resources (for multiple stacks and code branches) that are not clearly labelled. This makes it harder to identify and manage those resources outside of terraform (if necessary)
   3. Use tags: System, Stack, Branch, Resource (ID); In AWS tagging enables the use Resource Groups that can make it easy to review and manage all resources from one central view
   3. Use naming scheme that combines the above tags <System>_<Stack>_<Branch>_<Resource>
   4. The Terraform scripts must not hard-code to branch name at a minimum. Ideally the other values (except the resource id is shared/passed into main terraform script and passed down into modules.

3. Enable/automate sharing of information across stacks:
   1. Avoids hard-coding of information which becomes cumbersome and error-prone when using multiple stacks, and multiple branches per stack
   2. Approach
      2. Use terraform output specifications in one stack
      3. Pipe terraform outputs into a terraform configuration file
      4. Use terraform configuration file parameter to pass the output to the input of a dependent terraform script
3. Maintain state, output and configuration files on S3
  1. Organize by stack and branch on S3
     S3://<bucket>/terraform/state/stack/branch
  5. Organize pipeline configuration details (that should not be in the code) on S3
     S3://<bucket>/terraform/configuration/stack/branch
Note that by using a structure like this enables the use of fine-grained AWS policies (if desired)
5. Use multi-layer provisioning approach
   1. (Bootstrap) Manually create S3 bucket(s) used by provisioning tools
   2. Use terraform to provision Infrastructure (VPC, subnets, routing, NACLs, ELBs, EIPs , etc.
   3. Use terraform to provision resources (EC2 instances, ELBs, security groups, Elastic Cache, RDS instances, S3 buckets (not used by terraform, etc.)
   4. Use Ansible to provision OS and up on EC2 instances
   5. If using Docker, use Ansible to provision and create Docker images
6. Integrate into Jenkins Pipeline
   1. Enable running all provisioning from Jenkins pipelines
   2. Also enable "offline" provisioning development

## (Rough) Plan
1. Create pilot demonstrating how to apply practices using Terraform
   4. Create a simple provisioning stack using Terraform
   5. Trigger provisioning stack from Jenkins pipeline
   6. Test multi-branch approach (different branches, different resources and state)
      7. Ensure information sharing between stacks works properly
      8. Ensure works with multiple branches
   9. Create two stacks: simple infrastructure and a resources stack
   10.  Test triggering Ansible from Jenkins
   11. Test multi-branch pipelines
   12. Add notification mechanism to pipelines
   13. Increase scale and remove any issues for approach work for larger scale
   14. Add additional scripting to handle aspects that Terraform does not handle (yet), like tagging root volumes
2. In increments address specific features of the provisioning of the system following the approach as outlined in the pilot (step 1):
   3. Add infrastructure stack implementation details
   4. Add resources stack implementation details
   5. Add OS/application level provisioning details
