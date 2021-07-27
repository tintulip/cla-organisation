data "github_repositories" "repos" {
  query = "org:${var.org_name}"
}

resource "github_branch_protection_v3" "branch_protection" {
  for_each = toset(data.github_repositories.repos.names)
  repository     = each.key
  branch         = "main"
  enforce_admins = true
  require_signed_commits = true
}