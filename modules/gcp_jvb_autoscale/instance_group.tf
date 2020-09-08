
module "mig-jvb" {
  # Docs: https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/mig
  source            = "github.com/terraform-google-modules/terraform-google-vm/modules/mig"
  project_id        = var.project_id
  region            = var.region
  hostname          = "${var.app_prefix}-jvb"
  network           = var.network_name
  instance_template = google_compute_instance_template.jvb.self_link
  min_replicas      = var.min_instances
  max_replicas      = var.max_instances
/* seconds before metrics should be stable (read: after installation) */
  # It takes around 180 seconds for the startup script to complete
  # Setting cooldown to 200 to give it extra 20 seconds
  cooldown_period   = 200

  # Either target_size or autoscaler:
  # target_size = 2
  # TODO: Change this to use network packet rate targets
  autoscaling_cpu = [{
    target = var.autoscale_cpu_target
  }]
  autoscaling_enabled = true
}
