locals {
  watcher_env_vars = [
    # production environment variables
    { name = "LOG_LEVEL", value = var.log_level != null ? var.log_level : "debug" },
    { name = "ENVIRONMENT", value = "production" },
    { name = "ASSET_CHECK_INTERVAL", value = var.asset_check_interval },
    { name = "UPDATE_VARIABLE_INTERVAL", value = var.update_variable_interval },
    { name = "GAS_MULTIPLIER", value = var.gas_multiplier },
    { name = "PRIVATE_KEY", value = var.private_key },
    { name = "WEB3_SIGNER_URL", value = var.web3_signer_url },
    { name = "DISCORD_HOOK_URL", value = var.discord_hook_url },
    { name = "PAGER_DUTY_ROUTING_KEY", value = var.pager_duty_routing_key },
    { name = "SERVER_PORT", value = var.server_port != null ? var.server_port : "8080" },
    { name = "SERVER_HOST", value = var.server_host },
    { name = "SERVER_ADMIN_TOKEN", value = var.server_admin_token },
    { name = "TWILIO_NUMBER", value = var.twilio_number },
    { name = "TWILIO_TO_PHONE_NUMBERS", value = var.twilio_to_phone_numbers },
    { name = "TWILIO_ACCOUNT_SID", value = var.twilio_account_sid },
    { name = "TWILIO_AUTH_TOKEN", value = var.twilio_auth_token },
    { name = "TELEGRAM_CHAT_ID", value = var.telegram_chat_id },
    { name = "TELEGRAM_API_KEY", value = var.telegram_api_key },
    { name = "BETTER_UPTIME_EMAIL", value = var.better_uptime_email },
    { name = "BETTER_UPTIME_API_KEY", value = var.better_uptime_api_key },
    { name = "CUSTOM_RPC_PROVIDERS", value = var.custom_rpc_providers },
    # devnet scripts environment variables
    { name = "TENDERLY_ACCESS_KEY", value = var.tenderly_access_key },
    { name = "TENDERLY_ACCOUNT_ID", value = var.tenderly_account_id },
    { name = "TENDERLY_PROJECT_SLUG", value = var.tenderly_project_slug },
  ]
}
