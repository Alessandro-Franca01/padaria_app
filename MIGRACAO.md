# Migração: App mockado → API real

Este documento descreve a migração do `padaria_app` (antes 100% mockado, com `SharedPreferences`/`Future.delayed`) para consumir a API real `padaria_api` (Spring Boot), feita na branch `integrate-with-api`.

## Como rodar

1. **Subir o backend** (pasta `padaria_api/`, irmã desta):
   ```
   cd padaria_api
   mvn spring-boot:run
   ```
   Sobe em `http://localhost:8000`, com H2 em memória (os dados são recriados a cada start — categorias, produtos e o usuário admin são semeados automaticamente).

2. **Rodar o app** no emulador Android (a URL base já está configurada para isso):
   ```
   cd padaria_app
   flutter run
   ```

> A base URL está fixa em `lib/services/api_client.dart` como `http://10.0.2.2:8000/api` — esse é o alias que o **emulador Android** usa para acessar o `localhost` da máquina host. Se for testar em outro ambiente, ajuste essa constante:
> - Desktop/Web/Chrome: `http://127.0.0.1:8000/api`
> - Dispositivo físico na mesma rede Wi-Fi: `http://<IP-da-sua-máquina>:8000/api`

### Conta de admin (semeada no backend)
```
email: admin@padaria.com
senha: admin123
```
Usada para gerenciar Templates de assinatura (`/api/admin/subscription-templates`) e responder o chat (`/api/admin/chat-messages`) — não existe tela de admin no app, então isso é testado via Swagger (`http://localhost:8000/swagger-ui.html`) ou Postman.

## O que mudou no app

- **`lib/services/api_client.dart` (novo)**: cliente HTTP único (`ApiClient`), usado por todos os services. Guarda o token JWT no `FlutterSecureStorage` (mesma chave que já era usada por `AuthService`).
- **Removidos** (mortos, nunca usados): `api_service.dart`, `laravel_api_service.dart`, `auth_laravel_service.dart`.
- **`AuthService`**: login/registro/logout/atualização de perfil agora são chamadas reais. Registro passou a enviar telefone/endereço também.
- **`ProductService`**: produtos vêm de `GET /api/products` em vez de uma lista fixa de 8 itens.
- **`OrderService`**: pedidos são criados (`POST /api/orders`), listados (`GET /api/orders/user/{id}`) e cancelados (`POST /api/orders/{id}/cancel`) via API. Antes, o pedido feito no checkout nunca era salvo em lugar nenhum (bug pré-existente) — agora é.
- **`LoyaltyService`**: pontos são creditados automaticamente pelo servidor ao fechar um pedido (1 ponto a cada R$5). O app só consulta saldo (`GET /api/loyalty`) e resgata benefícios (`POST /api/loyalty/redeem`).
- **`ChatService`**: sem bot de resposta automática — mensagens são enviadas/recebidas de verdade (`GET`/`POST /api/chat-messages`). Respostas da padaria só aparecem quando um admin responde pelo Swagger/Postman.
- **`SubscriptionService` + `plans_screen.dart`**: mudança de comportamento mais visível. Antes, o cliente escolhia qualquer produto do catálogo para montar um plano. Agora, o Admin cria **Templates** (catálogos restritos de produtos permitidos) e o cliente escolhe um Template e, dentro dele, quais produtos e quantidades quer.
- **`CartService` não mudou** — o carrinho continua sendo só local (não existe carrinho persistido no backend, por design).

## Limitações conhecidas (aceitas de propósito)

- Itens de pedido/assinatura retornados pela API não trazem imagem/descrição/categoria do produto — o app usa uma imagem placeholder (`assets/images/paes_artesanais.jpeg`) nesses casos.
- Chat e listas de pedidos/assinaturas são atualizados por pull-to-refresh ou ao reabrir a tela — não há WebSocket/tempo real.
- Sem painel de admin no app — gestão de Templates e respostas de chat são feitas via Swagger/Postman.

## Checklist de teste manual

1. Registrar conta (com telefone/endereço) → editar perfil → dados persistem após logout/login.
2. Ver produtos reais, filtrar por categoria, adicionar ao carrinho.
3. Finalizar um pedido → ver em "Pedidos" → cancelar.
4. Ver saldo de fidelidade subir depois de um pedido.
5. Como admin (Swagger): criar um Template de assinatura → como cliente, assinar escolhendo produtos dele → ver em "Meus Planos" → editar.
6. Enviar mensagem no chat → responder como admin (Swagger) → puxar para atualizar no app.
