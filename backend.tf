terraform {
  cloud {
    organization = "gm-practice-org"
    workspaces {
      project = "AWS"
      name    = "demo-project-3-external-location"
    }
  }
}
