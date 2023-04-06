terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.3.1"
    }
  }
}
provider "vsphere" {
    user = "${var.vsphere_user}"
    password = "${var.vsphere_password}"
    vsphere_server = "${var.vsphere_server}"
    allow_unverified_ssl = true
}
data "vsphere_datacenter" "datacenter" {
  name = "datacenter"                     # Ce bloque extrait les données 
}                                         # du datacenter nommé déja "datacenter" sur vcenter 
data "vsphere_host" "hosts" {
  datacenter_id = data.vsphere_datacenter.datacenter.id  # Ce bloque extrait les données 
}                                                        # de l'ESXI connecter au Vcenter  
data "vsphere_resource_pool" "pool" {
  name = "VM_Terraform"                                 # création d'une plage 
  datacenter_id = data.vsphere_datacenter.datacenter.id # pour nos host 
}
data "vsphere_datastore" "datastore1" {
  name          = "datastore1"                          # Mentionner sur quel datastore 
  datacenter_id = data.vsphere_datacenter.datacenter.id # on va lancer la creation 
}
data "vsphere_network" "network" {
  name          = "VM Network"                          # Mentionner le nom du réseau  
  datacenter_id = data.vsphere_datacenter.datacenter.id # qui va contenir notre infra 
}
data "vsphere_virtual_machine" "template" {
  name          = "Temp_${var.template}"               # Mentionner le template deja 
  datacenter_id = data.vsphere_datacenter.datacenter.id# créer sur Vcenter 
}
/*
resource "vsphere_folder" "new_folder" {
  path           = "${var.lab}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
  type           = "vm"

  provisioner "local-exec" {
    command = "terraform state rm vsphere_folder.new_folder"
  }

}
*/
resource "vsphere_virtual_machine" "vm" {
  name = "${var.VM_name} "                                # Bloc de creation de ressource 
  resource_pool_id = data.vsphere_resource_pool.pool.id   # Mentionner la plage d'hote 
  datastore_id = data.vsphere_datastore.datastore1.id     # Mentionner la banque de données 
  num_cpus = data.vsphere_virtual_machine.template.num_cpus # pour les parametres de la Vm on 
  memory   = data.vsphere_virtual_machine.template.memory   # utilise les meme que des templates 
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware  = data.vsphere_virtual_machine.template.firmware
  wait_for_guest_ip_timeout  = 0    # cette commande c'est pour ne pas arreter la creation de la Vm                          
                                    # si elle met du temp a ne pas avir d'address IP 
   disk {
    label = "${var.VM_name} "
    size = data.vsphere_virtual_machine.template.disks.0.size  
   }

   clone {
    template_uuid = data.vsphere_virtual_machine.template.id   # pour cloner le template en VM 
    timeout = 60  
   }

network_interface {
    network_id = data.vsphere_network.network.id   # association de la VM a quel réseau "VM Network "
  }  
  provisioner "remote-exec" { 
 inline = [
              "sleep 240",
              "sed -i '2s/.*/${element(vsphere_virtual_machine.vm.guest_ip_addresses, 0)}/' /etc/inventory1.yml",
              "ansible-playbook -i /etc/inventory1.yml /etc/${var.playbook}.yml"
 ]
          

  connection { 
    type = "ssh" 
    host = "10.5.29.13" 
    user = "root"
    password = "root" 
  } 
}
}
