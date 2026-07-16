# ============================================================
# VPC
# ============================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  # IPv6はAmazonが自動でCIDRを割り当てる
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# ============================================================
# インターネットゲートウェイ（IPv4 & IPv6共用）
# ============================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# ============================================================
# パブリックサブネット × 2（ALB は 2AZ 必須）
# ============================================================
resource "aws_subnet" "public" {
  count  = 2
  vpc_id = aws_vpc.main.id

  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  # IPv6 CIDRをサブネットに割り当て（VPCの/56から/64を切り出す）
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
  assign_ipv6_address_on_creation = true

  tags = {
    Name    = "${var.project_name}-public-subnet-${count.index + 1}"
    Project = var.project_name
  }
}

# ============================================================
# AZ一覧を自動取得（リージョンに依存しない書き方）
# ============================================================
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================
# ルートテーブル（IPv4 & IPv6 両方をIGWへ）
# ============================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # IPv4デフォルトルート
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  # IPv6デフォルトルート
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rtb"
    Project = var.project_name
  }
}

# サブネットとルートテーブルを紐付け（2サブネット分）
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}