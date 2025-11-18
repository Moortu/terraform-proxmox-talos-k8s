// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terramate {
  config {
    run {
      env {
        TF_CLI_ARGS_apply   = "-var-file=../production.auto.tfvars"
        TF_CLI_ARGS_destroy = "-var-file=../production.auto.tfvars"
        TF_CLI_ARGS_plan    = "-var-file=../production.auto.tfvars"
      }
    }
  }
}
