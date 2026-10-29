# tc3-infra-db — desativado

Este repositório criava o banco do OS Service (RDS PostgreSQL) na Fase 3 do Tech Challenge.

**Na Fase 4, o Terraform do banco passou para o próprio serviço**, na pasta [`terraform/` do OS Service](https://github.com/LucasValada/tech-challenge-fiap/tree/develop/terraform). Assim cada microsserviço tem fila, banco e permissões no próprio repositório, como os bancos do Billing e do Execution.

O que estava aqui e para onde foi:

| Antes (aqui) | Agora (`tech-challenge-fiap/terraform/`) |
|---|---|
| RDS PostgreSQL `tc3-oficina-homolog`, subnet group e security group | `rds.tf`, com o banco renomeado para `oficina-os-db` |
| Parâmetros no SSM (`DATABASE_URL`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`) | `rds.tf`, com os mesmos nomes |
| Agente `nri-postgresql` do New Relic e o usuário de monitoria (`DB_MONITOR_PASSWORD`) | `newrelic-postgres.tf`, com as mesmas tags |

O código e o workflow de Terraform foram removidos deste repositório para que um merge aqui nunca crie um segundo banco nem sobrescreva os parâmetros do SSM do OS. O histórico continua no git.

A ordem de subida da infraestrutura passou a ser: `tc3-infra-k8s` → `tc3-auth-lambda` → `terraform/` dos serviços, aplicada pelo workflow **Ambiente** do [`tc3-infra-k8s`](https://github.com/tiagostorch/tc3-infra-k8s).
