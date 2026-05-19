terraform {
  cloud {
    organization = "gm-practice-org"
    workspaces {
      project = "AWS"
      name    = "demo-wksp-external-location"
    }
  }
}
