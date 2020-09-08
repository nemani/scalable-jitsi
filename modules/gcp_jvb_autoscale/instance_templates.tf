resource "tls_private_key" "jvb_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance_template" "jvb" {
  name          = "jitsi-jvb-template"
  tags          = ["jitsi-jvb", "autoscale-jvb"]
  machine_type  = var.machine_type

  # create a startup script with ssh keys
  metadata_startup_script = templatefile("${path.module}/../utils/startup_script.sh",
    {
      git_ssh_key=tls_private_key.jvb_ssh_key.private_key_pem,
      aws_creds=file("~/.aws/credentials"),
      app_prefix=var.app_prefix,
      app_pass=var.app_password
    }
  )

  metadata = {
    ssh-keys = "root:${tls_private_key.jvb_ssh_key.public_key_pem}"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "ubuntu-1804-bionic-v20200807"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = var.network_name
    access_config {}
  }

  service_account { scopes = ["userinfo-email", "compute-ro", "storage-ro", "logging-write"] }
  lifecycle { ignore_changes = [name] }
}
