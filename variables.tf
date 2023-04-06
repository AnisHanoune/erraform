variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "template"{
    description= "Choisissez le modèle à lancer : WS19 , Ubuntu22.04 , WIN10 "
} 
variable "VM_name" {
    description = " Choisissez le nom de votre VM : ad , iis , ubuntu , windows "
     
}
variable "playbook"{
    description = " Choisissez une tache : ad , iis , ping , membre "
}
