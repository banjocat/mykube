
resource "digitalocean_droplet" "master" {
    image = "ubuntu-16-04-x64"
    name = "kube-master-${count.index + 1}"
    region = "nyc1"
    size = "2gb"
    ssh_keys = ["ce:1b:52:47:94:e7:f5:43:dc:a7:6e:ac:5d:3e:d2:6d"]
    count = 1
    user_data = "${file("./bootstrap.sh")}"
}
resource "digitalocean_droplet" "nodes" {
    image = "ubuntu-16-04-x64"
    name = "kube-node-${count.index + 1}"
    region = "nyc1"
    size = "1gb"
    ssh_keys = ["ce:1b:52:47:94:e7:f5:43:dc:a7:6e:ac:5d:3e:d2:6d"]
    count = 1
    user_data = "${file("./bootstrap.sh")}"
}

resource "digitalocean_floating_ip" "master_ip" {
    droplet_id = "${digitalocean_droplet.master.0.id}"
    region = "${digitalocean_droplet.master.region}"
}

resource "digitalocean_floating_ip" "node_ip" {
    droplet_id = "${digitalocean_droplet.nodes.0.id}"
    region = "${digitalocean_droplet.master.region}"
}


resource "digitalocean_firewall" "kube" {
    name = "kube"

    droplet_ids = ["${concat(digitalocean_droplet.nodes.*.id, digitalocean_droplet.master.*.id)}"]
    inbound_rule = [
        {
            protocol = "tcp"
            port_range = "22"
            source_addresses = ["0.0.0.0/0", "::/0"]
        },
        {
            protocol = "tcp"
            port_range = "all"
            source_addresses = ["${concat(digitalocean_droplet.nodes.*.ipv4_address, digitalocean_droplet.master.*.ipv4_address)}"]
        },
        {
            protocol = "tcp"
            port_range = "all"
            source_addresses = ["${digitalocean_floating_ip.master_ip.ip_address}", "${digitalocean_floating_ip.node_ip.ip_address}"]
        },
    ]

    outbound_rule {
        protocol = "tcp"
        port_range = "all"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}

output "master" {
    value = "${digitalocean_droplet.master.*.ipv4_address}"
}

output "nodes" {
    value = "${digitalocean_droplet.nodes.*.ipv4_address}"
}

output "master-float-1" {
    value = "${digitalocean_floating_ip.master_ip.ip_address}"
}

output "node-float-1" {
    value = "${digitalocean_floating_ip.node_ip.ip_address}"
}
