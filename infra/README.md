# Azure DevOps インフラ環境構築

1. GitHub リポジトリからダウンロード

    ```
    git pull <URL>
    ```

1. 変数ファイル（ `terraform.tfvars` ）として以下の変数を作成

    ```
    TENANT_ID       = {tenant id}         # テナントID
    SUBSCRIPTION_ID = {subscription id}   # サブスクリプションID
    location        = "japaneast"         # 展開するリージョン名
    prj             = {project name}      # プロジェクト名。接頭辞に利用。任意。例：azure-devops
    env             = {environment name}  # 環境名。接頭辞に利用。任意。例：test
    username        = {agent vm user}     # エージェントVMのユーザー名
    password        = {agent vm password} # エージェントVMのパスワード
    ```

1. 初期化、適用を実施

    ```
    az login
    az account set -s <SUBSCRIPTION_ID>
    terraform init
    terraform apply -auto-approve
    ```

