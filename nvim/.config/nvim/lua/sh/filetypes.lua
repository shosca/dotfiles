vim.filetype.add {
  extension = {
    cr = "crystal",
    mk = "make",
    fnl = "fennel",
    wiki = "markdown",
  },
  filename = {
    ["poetry.lock"] = "toml",
    ["yarn.lock"] = "yaml",
    [".env"] = "sh",
    [".envrc"] = "sh",
    ["*.env"] = "sh",
    ["*.envrc"] = "sh",
  },
  pattern = {
    ["Dockerfile*"] = "dockerfile",
    ["Jenkinsfile*"] = "groovy",
    ["go.sum"] = "gosum",
    ["go.mod"] = "gomod",
  },
}
