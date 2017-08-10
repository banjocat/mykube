variable "do_token" {}

provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_droplet" "master" {
    image = "ubuntu-16-04-x64"
    name = "kube-master-${count.index + 1}"
    region = "nyc1"
    size = "512mb"
    ssh_keys = ["ce:1b:52:47:94:e7:f5:43:dc:a7:6e:ac:5d:3e:d2:6d"]
    count = 1
}

resource "digitalocean_droplet" "nodes" {
    image = "ubuntu-16-04-x64"
    name = "kube-node-${count.index + 1}"
    region = "nyc1"
    size = "512mb"
    ssh_keys = ["ce:1b:52:47:94:e7:f5:43:dc:a7:6e:ac:5d:3e:d2:6d"]
    count = 1
}

resource "digitalocean_floating_ip" "master_ip" {
    droplet_id = "${digitalocean_droplet.master.id}"
    region = "${digitalocean_droplet.master.region}"
}

output "master" {
    value = "${digitalocean_droplet.master.*.ipv4_address}"
}

output "nodes" {
    value = "${digitalocean_droplet.nodes.*.ipv4_address}"
}
