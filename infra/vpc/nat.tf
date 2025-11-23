# ---------------------------
# NAT GATEWAY SETUP
# ---------------------------

# 1. Allocate an Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "acme-nat-eip"
  }
}

# 2. NAT Gateway (must be in a public subnet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id   # NAT in public subnet-a

  tags = {
    Name = "acme-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}
