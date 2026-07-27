# Casos de Teste Manual — Pedidos (App Flutter)

Roteiro para validar manualmente as correções feitas no fluxo de Pedidos (ver `PLANO-correcoes-pedidos.md` na raiz do repositório principal). Rodar o app (`flutter run`) com a API local ativa, logado como cliente.

---

## 1. Checkout — validação de data/hora de entrega

| # | Passo | Esperado |
|---|-------|----------|
| 1.1 | Adicionar item(ns) ao carrinho e ir para Checkout. | Tela carrega normalmente. |
| 1.2 | Selecionar a data de **hoje** e um horário **já passado** (ex.: se agora são 15h, escolher 10h). Preencher endereço e finalizar pedido. | SnackBar de aviso "Selecione uma data e hora de entrega futuras" — pedido **não** é enviado. |
| 1.3 | Selecionar data de hoje e horário **futuro** (ex.: daqui a 1h). Finalizar pedido. | Pedido criado com sucesso, navega para tela de confirmação. |
| 1.4 | Selecionar uma data futura (amanhã ou depois) com qualquer horário. Finalizar pedido. | Pedido criado com sucesso. |
| 1.5 | Tentar finalizar sem selecionar data ou hora. | Aviso "Por favor, selecione data e hora de entrega" (comportamento já existente, deve continuar funcionando). |

## 2. Cancelamento de pedido

| # | Passo | Esperado |
|---|-------|----------|
| 2.1 | Abrir detalhes de um pedido `Pendente` ou `Confirmado` (em Meus Pedidos). | Botão "Cancelar Pedido" visível. |
| 2.2 | Tocar em "Cancelar Pedido" e confirmar no diálogo. | Pedido cancelado com sucesso, SnackBar de confirmação, volta para a listagem. |
| 2.3 | Abrir detalhes de um pedido em `Em preparação`, `Em entrega` ou `Concluído`. | Botão "Cancelar Pedido" **não** aparece. |
| 2.4 (opcional, valida o backend) | Se possível forçar uma chamada de cancelamento em pedido `Em preparação` via outra via (ex.: Postman), confirmar que a API agora recusa (400/409) mesmo que a UI permitisse. | Erro retornado, sem quebrar o app. |

## 3. Fluxo geral de pedidos

| # | Passo | Esperado |
|---|-------|----------|
| 3.1 | Criar um pedido recorrente sem marcar nenhum dia da semana. | Aviso "Selecione pelo menos um dia para o pedido recorrente" — pedido não enviado. |
| 3.2 | Criar pedido recorrente marcando ao menos um dia. | Pedido criado com sucesso, tela de detalhes mostra "Pedido Recorrente" com os dias selecionados. |
| 3.3 | Acompanhar um pedido sendo avançado no painel admin (Pendente → Preparando, pulando Confirmado) e dar refresh na tela de detalhes do app. | Status e descrição atualizam corretamente para "Em preparação". |
| 3.4 | Pedido `Concluído`. | Botão "Fazer Pedido Novamente" aparece; botão de cancelar não aparece. |
