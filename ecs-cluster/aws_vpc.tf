
resource "aws_vpc" "armory_ecs" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "armory-testing-vpc"
    Owner = "Armory"
  }
}
resource "aws_subnet" "armory_ecs" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.armory_ecs.id}"
  map_public_ip_on_launch = true

  tags = {
    Name = "armory-ecs"
    Owner = "Armory"
    immutable_metadata = "{\"purpose\":\"ecs-subnet\"}"
  }
}

resource "aws_internet_gateway" "armory_ecs" {
  vpc_id            = "${aws_vpc.armory_ecs.id}"

  tags = {
    Name = "armory-ecs-igw"
    Owner = "Armory"
  }
}

resource "aws_route_table" "armory_ecs" {
  vpc_id            = "${aws_vpc.armory_ecs.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.armory_ecs.id}"
  }

  tags = {
    Name = "armory-testing-rtb-public"
    Owner = "Armory"
  }
}

resource "aws_route_table_association" "armory_ecs" {
  count = 2

  subnet_id      = "${aws_subnet.armory_ecs.*.id[count.index]}"
  route_table_id = "${aws_route_table.armory_ecs.id}"
}
