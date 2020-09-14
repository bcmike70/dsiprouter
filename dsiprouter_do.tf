provider "digitalocean" {
}

data "digitalocean_ssh_key" "jump" {
  name = "Jump"
}

resource "digitalocean_droplet" "dsiprouterDroplet" {
        name = "${var.hostname}"
        region = "${var.dc}"
        size="1gb"
        image="debian-9-x64"
	ssh_keys = [ "${data.digitalocean_ssh_key.jump.fingerprint}" ]
	user_data = "${template_file.userdata_web.rendered}"
}

output "ip" {
  value = "${digitalocean_droplet.dsiprouterDroplet.*.ipv4_address}"
}

