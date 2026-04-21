resource "aws_cloudfront_distribution" "web_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Origin 1: S3 (frontend estático)
  origin {
    domain_name              = aws_s3_bucket.app_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # Origin 2: ALB (backend/EC2) — mantido pra arquitetura completa
  origin {
    domain_name = aws_lb.web_alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Frontend via S3 (rota padrão)
default_cache_behavior {
  target_origin_id       = "s3-origin"
  viewer_protocol_policy = "redirect-to-https"

  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]

  # Adiciona isso:
  function_association {
    event_type   = "viewer-request"
    function_arn = aws_cloudfront_function.url_rewrite.arn
  }

  forwarded_values {
    query_string = false
    cookies {
      forward = "none"
    }
  }
}

  # Erro 403/404 redireciona pro index.html (necessário pro Next.js)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_function" "url_rewrite" {
  name    = "url-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-EOT
    async function handler(event) {
      var request = event.request;
      var uri = request.uri;
      
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      } else if (!uri.includes('.')) {
        request.uri += '/index.html';
      }
      
      return request;
    }
  EOT
}