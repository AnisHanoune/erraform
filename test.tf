  terraform {
  required_providers {                  # Cette partie on la récupere depuis le site
    vsphere = {                         # https://registry.terraform.io/
      source = "hashicorp/vsphere"      # On selectionne notre provider
      version = "2.3.1"                 # On copie le code, on le colle dans notre fichier de config 
    }
  }
}/*folder= vsphere_folder.new_folder.path*/
provider "vsphere" {
    user = "${var.vsphere_user}"         # Nom utilisateur de Vcenter 
    password = "${var.vsphere_password}" # Mot de passe du Vcenter 
    vsphere_server = "${var.vsphere_server}" # Address IP Vcenter 
    allow_unverified_ssl = true              # pour ignorer la verification SSL 
}
resource "null_resource" "vm"{
}