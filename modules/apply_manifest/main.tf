resource "null_resource" "kubectl_apply" {

  provisioner "local-exec" {
    command = "cat <<EOF | kubectl --kubeconfig ${var.kubeconfig_file} apply -f -\n${var.manifest}EOF\n"
  }

}

