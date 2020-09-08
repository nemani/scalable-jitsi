terragrunt = {
      # Put your Terragrunt configuration here
}

auth_file = "./creds.json"
region = "asia-southeast2"
project_id = "prod"
machine_type = "e2-medium"

min_instances = 15
max_instances = 20

# We assume network has the respective ports open
# TODO: Create network using TF
network_name = "jvb-network"
autoscale_cpu_target = 0.5

# TODO: Add network packet autoscalling
