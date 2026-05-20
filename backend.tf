terraform {
  cloud {
    organization = "gm-practice-org"
    workspaces {
      project = "AWS"
      name    = "demo-project-2-external-location"
    }
  }
}
