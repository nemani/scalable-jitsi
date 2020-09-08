export TF_VAR_app_password=$(grep PASSWORD ~/jitsi-config/jvb/sip-communicator.properties | cut -d"=" -f 2)
export TF_VAR_app_prefix=$(hostname | cut -d. -f1)

