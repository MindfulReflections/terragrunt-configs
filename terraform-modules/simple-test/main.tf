
resource "aws_s3_bucket" "test_bucket" {
  bucket_prefix = "${var.name}-test-bucket-"
  tags          = var.tags
}
