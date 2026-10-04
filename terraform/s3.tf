resource "aws_s3_bucket" "tf-s3-bucket" {
  bucket = "nodejs-bucket07486"

  tags = {
    Name        = "My bucket for s3 resource terraform"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "tf-s3-object" {
  bucket   = "nodejs-bucket07486"
  for_each = fileset("../public/images", "**")
  key      = "images/${each.key}"
  source   = "../public/images/${each.key}"
}
