output "git_branch" {
  value       = data.external.git.result.git_branch
  description = "The current git branch"
}

output "git_tag" {
  value       = data.external.git.result.git_tag == "" ? "HEAD" : data.external.git.result.git_tag
  description = "The current git tag"
}

output "git_repo" {
  value       = data.external.git.result.git_repo
  description = "The current git repo"
}

output "git_path" {
  value       = data.external.git.result.git_path
  description = "The current git path"
}

output "git_commit_sha" {
  value       = data.external.git.result.git_commit_sha
  description = "The current git commit sha"
}
