# ---------------------------
# PUBLIC SUBNETS
# ---------------------------
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "acme-public-${count.index}"
    Type = "public"
  }
}

# ---------------------------
# PRIVATE SUBNETS
# ---------------------------
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "acme-private-${count.index}"
    Type = "private"
  }
}
