data "external" "git" {
  program = ["bash", "-c", <<EOF
    echo '{
      "git_branch": "'$(git rev-parse --abbrev-ref HEAD)'",
      "git_tag": "'$(git tag --contains HEAD)'",
      "git_repo": "'$(git config --get remote.origin.url)'",
      "git_path": "'$(git rev-parse --show-prefix)'",
      "git_commit_sha": "'$(git rev-parse HEAD)'"
    }'
EOF
  ]
}
