# shellcheck disable=SC2155
export AZDO_PERSONAL_ACCESS_TOKEN=$(cat .devops.pat)
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/leiferiksenau"
export AZDO_GITHUB_SERVICE_CONNECTION_PAT=$(cat .github.pat)