#!/bin/env bash

# Load additional functions
source lib/display_message.sh
source lib/run_command.sh

# Setup some variables
gitlab_namespace="gitlab-system"
gitlab_initial_root_user="root"
gitlab_initial_root_pass=$(oc -n ${gitlab_namespace} get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d)
gitlab_base_url="https://"
gitlab_base_url+=$(oc -n ${gitlab_namespace} get route gitlab -o jsonpath='{.spec.host}')
openshift_gitlab_toolbox_pod=$(oc -n ${gitlab_namespace} get pod -l app=toolbox -o jsonpath='{.items[].metadata.name}')

# Display GitLab credentials
display_message "show-date" "INFO" "GitLab Config" "User: ${gitlab_initial_root_user}"
display_message "show-date" "INFO" "GitLab Config" "Pass: ${gitlab_initial_root_pass}"
display_message "show-date" "INFO" "GitLab Config" "URL: ${gitlab_base_url}"

# Platform user creation vars
platform_user_name="demo-platform-admin"
platform_user_pass="iCPMSRchUbUmSu4RFfDxme"
platform_user_mail="${platform_user_name}@example.com"
platform_user_object="user = User.create();
user.name = '${platform_user_name}';
user.username = '${platform_user_name}';
user.password = '${platform_user_pass}';
user.confirmed_at = '01/09/2023';
user.admin = true;
user.email = '${platform_user_mail}';
user.save!;
token = user.personal_access_tokens.create(scopes: [:api], name: 'automation token ${platform_user_name}', expires_at: '01/09/2024');
puts token.token
"
platform_user_check="user = User.find_by_username('${platform_user_name}');
puts user.name
"

# Check if platform user exists
platfrom_user_find=$(oc -n ${gitlab_namespace} rsh ${openshift_gitlab_toolbox_pod} gitlab-rails runner "${platform_user_check}")

case "$platfrom_user_find" in
  *$platform_user_name*)
    display_message "show-date" "INFO" "GitLab Config" "User ${platform_user_name} already exists."
    ;;
  *)
    display_message "show-date" "INFO" "GitLab Config" "User ${platform_user_name} does not exist, creating user..."
    platfrom_user_create=$(oc -n ${gitlab_namespace} rsh $openshift_gitlab_toolbox_pod gitlab-rails runner "${platform_user_object}")
    display_message "show-date" "INFO" "GitLab Config" "URL: ${platfrom_user_create}"
    oc create secret generic platform-user-creds -n ${gitlab_namespace} \
      --from-literal=gitlab_initial_root_user=${gitlab_initial_root_user} \
      --from-literal=gitlab_initial_root_pass=${gitlab_initial_root_pass} \
      --from-literal=gitlab_base_url=${gitlab_base_url} \
      --from-literal=platform_user_name=${platform_user_name} \
      --from-literal=platform_user_pass=${platform_user_pass} \
      --from-literal=platform_user_token=${platfrom_user_create}
    ;;
esac

# Perform setup calls

gitlab_initial_root_user=$(oc get secret -n ${gitlab_namespace} platform-user-creds -o jsonpath='{.data.gitlab_initial_root_user}' | base64 -d | tr -d '\r')
gitlab_initial_root_pass=$(oc get secret -n ${gitlab_namespace} platform-user-creds -o jsonpath='{.data.gitlab_initial_root_pass}' | base64 -d | tr -d '\r')
gitlab_base_url=$(oc get secret -n ${gitlab_namespace} platform-user-creds -o jsonpath='{.data.gitlab_base_url}' | base64 -d | tr -d '\r')
platform_user_name=$(oc get secret -n ${gitlab_namespace} platform-user-creds -o jsonpath='{.data.platform_user_name}' | base64 -d | tr -d '\r')
platform_user_pass=$(oc get secret -n ${gitlab_namespace} platform-user-creds -o jsonpath='{.data.platform_user_pass}' | base64 -d | tr -d '\r')
platform_user_token=$(oc get secret -n ${gitlab_namespace} platform-user-creds -o jsonpath='{.data.platform_user_token}' | base64 -d | tr -d '\r')

display_message "show-date" "INFO" "GitLab Config" "gitlab_initial_root_user: ${gitlab_initial_root_user}"
display_message "show-date" "INFO" "GitLab Config" "gitlab_initial_root_pass: ${gitlab_initial_root_pass}"
display_message "show-date" "INFO" "GitLab Config" "gitlab_base_url: ${gitlab_base_url}"
display_message "show-date" "INFO" "GitLab Config" "platform_user_name: ${platform_user_name}"
display_message "show-date" "INFO" "GitLab Config" "platform_user_pass: ${platform_user_pass}"
display_message "show-date" "INFO" "GitLab Config" "platform_user_token: ${platform_user_token}"

# Create platform group

create_group_platform_json='{
  "name": "demo-platform",
  "path": "demo-platform",
  "description": "This is a demo platform group",
  "auto_devops_enabled": false,
  "default_branch_protection": 0,
  "emails_disabled": false,
  "lfs_enabled": true,
  "mentions_disabled": true,
  "project_creation_level": "developer",
  "request_access_enabled": true,
  "require_two_factor_authentication": false,
  "two_factor_grace_period": 48,
  "subgroup_creation_level": "maintainer",
  "share_with_group_lock": false,
  "visibility": "public",
  "membership_lock": false
}'

curl --request POST \
  --header "PRIVATE-TOKEN: $platform_user_token" \
  --header "Content-Type: application/json" \
  -d "$create_group_platform_json" \
  "$gitlab_base_url/api/v4/groups/" | jq
