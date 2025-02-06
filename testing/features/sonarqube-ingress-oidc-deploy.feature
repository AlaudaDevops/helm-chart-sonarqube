# language: zh-CN
@sonarqube-operator-deploy
@e2e
@sonarqube-e2e
功能: 支持通过 operator 部署 SonarQube

    @smoke
    @automated
    @priority-high
    @sonarqube-operator-deploy-ha
    场景: 通过默认配置部署 Sonarqube
        假定 集群已安装 ingress controller
        并且 已添加域名解析
            | domain                        | ip           |
            | test-https-sso.example.com    | <ingress-ip> |
        并且 集群已存在存储类
        并且 命名空间 "testing-sonarqube-operator" 已存在
        并且 已导入 "SonarQube 数据库" 资源: "./testdata/resources/pg-postgresql.yaml"
        并且 已导入 "初始化 SonarQube 数据的 job" 资源: "./testdata/resources/job-init-sonar-db.yaml"
        并且 已导入 "域名 TLS 证书" 资源: "./testdata/resources/secret-tls-cert.yaml"
        并且 已导入 "自定义 root 密码" 资源: "./testdata/resources/custom-root-password.yaml"
        并且 执行 "sso 配置" 脚本成功
            | command                                                                                                             |
            | sh ./testdata/script/prepare-sso-config.sh '<config.{{.acp.baseUrl}}>' '<config.{{.acp.token}}>' '<config.{{.acp.cluster}}>' |
        当 已导入 "sonarqube 实例" 资源
            """
            yaml: "./testdata/ingress-oidc.yaml"
            patches: 
            - kind: "Sonarqube"
              apiVersion: "operator.alaudadevops.io/v1alpha1"
              metadata:
                name: "ingress-oidc"
              data:
                spec:
                  helmValues:
                    oidc:
                      issuer: <config.{{.acp.baseUrl}}>/dex
            """
        那么 "sonarqube" 可以正常访问
            """
            url: https://test-https-sso.example.com
            timeout: 10m
            """
        并且 "Sonarqube 组件" 资源检查通过
            | kind        | apiVersion | name                     | path            | value | interval | timeout |
            | Deployment  | apps/v1    | ingress-oidc-sonarqube   | $.spec.replicas | 1     | 30s      | 10m     |
        并且 "ingress-oidc" 实例资源检查通过
