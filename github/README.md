# GitHub

this terraform stack contains the configurations needed to manage GitHub organisation


## Authenticating to GH

Have the `GITHUB_TOKEN` environment variable populated, the provider will pick it up as per [provider documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token)

This stack needs to authenticate to GH to enable branch protection for all repositories in the GH organisation, this currently requires the `admin:org` scope and the `repo` scope being enabled for your Personal Access Token as per [GH API documentation](https://docs.github.com/en/rest/reference/repos#update-branch-protection),  (last accessed Jul 2021).

```bash
GITHUB_TOKEN=<your personal access token> terraform init
GITHUB_TOKEN=<your personal access token> terraform plan
GITHUB_TOKEN=<your personal access token> terraform apply
```