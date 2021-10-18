
resource "google_cloudfunctions_function" "functionHttp" {
  provider = google-beta

  name        = "${var.service_name}-${var.function_name}"
  description = "${var.function_description}"
  runtime     = "java11"

  available_memory_mb   = var.memory
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "${var.entry_point_class_name}"
  trigger_http = true
}

resource "google_storage_bucket" "bucket" {
  provider = google-beta
  name = "${var.service_name}-${var.function_name}-cloud-function-bucket"
}

resource "google_storage_bucket_object" "archive" {
  provider = google-beta
  name   = "${var.service_name}-${var.function_name}-${filemd5(var.source_zip_file)}.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${var.source_zip_file}"
}


# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  provider = google-beta
  project = google_cloudfunctions_function.functionHttp.project
  region = google_cloudfunctions_function.functionHttp.region
  cloud_function = google_cloudfunctions_function.functionHttp.name

  role = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


