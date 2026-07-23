# Análise de consumo da API (app Flutter + painel admin Next.js)

> Gerado em 2026-07-22, ampliado no mesmo dia. Compara os endpoints expostos pela `padaria_api` (Spring Boot) com o que é efetivamente chamado pelos dois clientes que ela serve:
> - **`padaria_app`** (Flutter, cliente final) — base URL `http://10.0.2.2:8000/api` (emulador Android), configurada em `lib/services/api_client.dart`.
> - **`padaria_admin`** (Next.js App Router, painel administrativo) — base URL `NEXT_PUBLIC_API_URL` (default `http://localhost:8000`), via wrapper `apiFetch`/`apiGet`/`apiPost`/`apiPut`/`apiDelete` em `lib/api.ts`.
>
> Legenda: ✅ App = consumido pelo Flutter · ✅ Admin = consumido pelo Next.js · ❌ = não consumido por nenhum dos dois.

## 1. Auth / User

`AuthController` (`/api`), `UserController` (`/api/users`), `AdminUserController` (`/api/admin/users`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| POST `/api/register` | ✅ `auth_service.dart` (`register()`) — `register_screen.dart` | ❌ não consumido (admin não tem tela de cadastro) |
| POST `/api/login` | ✅ `auth_service.dart` (`login()`) — `login_screen.dart` | ✅ `contexts/AuthContext.tsx` (`login()`), valida `role === "ADMIN"` |
| POST `/api/logout` | ✅ `auth_service.dart` (`logout()`) | ❌ **não consumido** — logout do admin é só local (limpa cookie + redirect), não chama a API |
| PUT `/api/users/me` | ✅ `auth_service.dart` (`updateProfile()`) — `profile_screen.dart` | ❌ não consumido (sem tela de perfil próprio no admin) |
| GET `/api/admin/users` | ❌ não consumido | ✅ `app/(painel)/clientes/page.tsx` (lista única, separada em abas "clientes"/"administradores" por `role` client-side) |

## 2. Categoria

`CategoryController` (`/api/categories`), `AdminCategoryController` (`/api/admin/categories`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| GET `/api/categories` | ❌ **não consumido.** Categorias hardcoded em `lib/models/category_item.dart`; filtro usa strings distintas extraídas dos produtos já carregados | ✅ `app/(painel)/categorias/page.tsx` e `app/(painel)/produtos/page.tsx` (para o `<Select>` de categoria) |
| POST `/api/admin/categories` | ❌ não consumido | ✅ `categorias/page.tsx` (`handleSubmit`, criação) |
| PUT `/api/admin/categories/{id}` | ❌ não consumido | ✅ `categorias/page.tsx` (`handleSubmit`, edição) |
| DELETE `/api/admin/categories/{id}` | ❌ não consumido | ✅ `categorias/page.tsx` (`handleDelete`) |

## 3. Produto

`ProductController` (`/api/products`), `AdminProductController` (`/api/admin/products`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| GET `/api/products` | ✅ `product_service.dart` — `products_screen.dart`, `home_screen.dart`, `product_detail_screen.dart` | ✅ `produtos/page.tsx`; também `assinaturas/page.tsx` (escolher produtos de um template) |
| GET `/api/products/category/{id}` | ❌ **não consumido.** Filtro client-side em vez do endpoint do servidor | ❌ não consumido (admin lista tudo, sem filtro server-side por categoria) |
| POST `/api/admin/products` | ❌ não consumido | ✅ `produtos/page.tsx` (`handleSubmit`, criação) |
| PUT `/api/admin/products/{id}` | ❌ não consumido | ✅ `produtos/page.tsx` (`handleSubmit`, edição) |
| DELETE `/api/admin/products/{id}` | ❌ não consumido | ✅ `produtos/page.tsx` (`handleDeactivate` — usado como "Desativar", não exclusão física) |
| POST `/api/admin/products/{id}/image` | ❌ não consumido | ✅ `produtos/page.tsx` (`handleUploadImage`, `FormData`) |

## 4. Pedido

`OrderController` (`/api/orders`), `AdminOrderController` (`/api/admin/orders`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| POST `/api/orders` | ✅ `order_service.dart` (`createOrder()`) — `checkout_screen.dart` | ❌ (fluxo é do cliente) |
| GET `/api/orders/user/{userId}` | ✅ `order_service.dart` (`fetchOrders()`) — `orders_screen.dart` | ❌ |
| GET `/api/orders/{orderId}` | ❌ **não consumido.** Telas reaproveitam o objeto já carregado da lista/criação | ❌ |
| POST `/api/orders/{orderId}/cancel` | ✅ `order_service.dart` (`cancelOrder()`) | ❌ |
| GET `/api/admin/orders` | ❌ não consumido | ✅ `pedidos/page.tsx` (lista, filtro de status client-side) |
| GET `/api/admin/orders/{orderId}` | ❌ não consumido | ❌ **não consumido.** O modal "Ver detalhes" (`openDetail(order)`) reaproveita o item já vindo da listagem — endpoint efetivamente morto do ponto de vista do admin |
| PUT `/api/admin/orders/{orderId}/status` | ❌ não consumido | ✅ `pedidos/page.tsx` (`handleUpdateStatus`) |
| POST `/api/admin/orders/{orderId}/refund` | ❌ não consumido | ✅ `pedidos/page.tsx` (`handleRefund`) |

## 5. Assinatura

`SubscriptionController` (`/api/subscriptions`), `SubscriptionTemplateController` (`/api/subscription-templates`), `AdminSubscriptionTemplateController` (`/api/admin/subscription-templates`), `AdminSubscriptionInvoiceController` (`/api/admin/subscription-invoices`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| GET `/api/subscription-templates` (público) | ✅ `subscription_service.dart` (`fetchTemplates()`) — `subscription_plans_list_screen.dart` | ❌ |
| GET `/api/subscription-templates/{id}` (público) | ❌ **não consumido** — sem busca individual por id | ❌ |
| POST `/api/subscriptions` | ✅ `subscription_service.dart` (`createSubscription()`) | ❌ |
| GET `/api/subscriptions/user/{userId}` | ✅ `subscription_service.dart` (`fetchUserPlans()`) | ❌ |
| GET `/api/subscriptions/{id}` | ❌ **não consumido** — sem busca individual por id | ❌ |
| PUT `/api/subscriptions/{id}` | ✅ `subscription_service.dart` (`updateSubscription()`) | ❌ |
| POST `/api/admin/subscription-templates` | ❌ não consumido | ✅ `assinaturas/page.tsx` (`handleSubmit`, criação) |
| GET `/api/admin/subscription-templates` | ❌ não consumido | ✅ `assinaturas/page.tsx` (lista) |
| GET `/api/admin/subscription-templates/{id}` | ❌ não consumido | ❌ **não consumido.** Modal de edição (`openEdit(template)`) reaproveita o item já vindo da lista — endpoint efetivamente morto |
| PUT `/api/admin/subscription-templates/{id}` | ❌ não consumido | ✅ `assinaturas/page.tsx` (`handleSubmit`, edição) |
| GET `/api/admin/subscription-invoices` | ❌ não consumido | ✅ `faturamento/page.tsx` (tabela de faturas) |
| POST `/api/admin/subscription-invoices/{id}/mark-paid` | ❌ não consumido | ✅ `faturamento/page.tsx` (`handleMarkPaid`) |
| POST `/api/admin/subscription-invoices/{id}/mark-pending` | ❌ não consumido | ✅ `faturamento/page.tsx` (`handleMarkPending`) |

## 6. Chat

`ChatController` (`/api/chat-messages`), `AdminChatController` (`/api/admin/chat-messages`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| POST `/api/chat-messages` | ✅ `chat_service.dart` (`sendMessage()`) — `chat_screen.dart` | ❌ |
| GET `/api/chat-messages` | ✅ `chat_service.dart` (`fetchMessages()`) | ❌ |
| GET `/api/admin/chat-messages` | ❌ não consumido | ✅ `chat/page.tsx` (lista de conversas) |
| GET `/api/admin/chat-messages/{userId}` | ❌ não consumido | ✅ `chat/page.tsx` (thread da conversa selecionada) |
| POST `/api/admin/chat-messages/{userId}` | ❌ não consumido | ✅ `chat/page.tsx` (`handleSend`, resposta do admin) |

## 7. Fidelidade

`LoyaltyController` (`/api/loyalty`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| GET `/api/loyalty` | ✅ `loyalty_service.dart` (`fetchStatus()`) | ❌ **não consumido** — não há tela de fidelidade no admin |
| POST `/api/loyalty/redeem` | ✅ `loyalty_service.dart` (`redeem()`) | ❌ não consumido |

Não há tela dedicada de fidelidade em `lib/screens/` do app — provavelmente exibida dentro de `profile_screen.dart`. No admin não existe nenhuma superfície de gestão de fidelidade (ex.: ver saldo de pontos de um cliente, ajustar pontos manualmente).

## 8. Billing / Dashboard (admin-only)

`AdminBillingController` (`/api/admin/billing`), `AdminBillingGoalController` (`/api/admin/billing/goals`), `AdminDashboardController` (`/api/admin/dashboard`)

| Endpoint | App (Flutter) | Admin (Next.js) |
|---|---|---|
| GET `/api/admin/billing/summary` | ❌ | ✅ `faturamento/page.tsx` (cards de resumo, `from`/`to`) |
| GET `/api/admin/billing/revenue` | ❌ | ✅ `faturamento/page.tsx` → `RevenueChart.tsx` (`from`/`to`/`granularity`) |
| GET `/api/admin/billing/breakdown` | ❌ | ✅ `faturamento/page.tsx` (breakdown por dimensão, `from`/`to`/`dimension`) |
| GET `/api/admin/billing/transactions` | ❌ | ✅ `faturamento/page.tsx` (extrato, `from`/`to`/`type`) |
| GET `/api/admin/billing/goals/{year}/{month}` | ❌ | ✅ `faturamento/page.tsx` (card de meta do mês corrente) |
| PUT `/api/admin/billing/goals/{year}/{month}` | ❌ | ✅ `faturamento/page.tsx` (`handleSaveGoal`) |
| GET `/api/admin/dashboard/summary` | ❌ | ✅ `dashboard/page.tsx` (cards, pedidos por status, pedidos recentes) |

## 9. Dados estáticos/mock ainda usados no app Flutter (em vez da API)

Levantamento adicional (2026-07-22): busca por listas hardcoded, imagens estáticas usadas como se fossem dados dinâmicos, arquivos mock/fake/dummy e comentários TODO relacionados a migração. Confirma e amplia o achado de `category_item.dart` já citado na seção 2.

| Arquivo | Dado estático | Usado em | Endpoint real disponível? |
|---|---|---|---|
| `lib/models/category_item.dart` | 6 categorias hardcoded + imagens locais (`assets/images/categories/`) | `home_screen.dart` (grid "Nossas Especialidades") | ✅ `GET /api/categories` (já citado na seção 2) |
| `lib/models/discount_item.dart` | 3 promoções hardcoded (percentuais/descrições fixas) + imagens locais (`assets/images/descontos/`); ainda tem entradas comentadas apontando para `via.placeholder.com` | `home_screen.dart` (carrossel "Promoções e Descontos") | ❌ **Não existe endpoint de descontos/promoções na API** — precisaria ser criado no backend se o negócio quiser promoções reais |
| `lib/widgets/carousel_item.dart` | 3 cards "destaque" hardcoded + imagens locais | `home_screen.dart` (carrossel "Destaques") | ✅ **Já existe e está pronto, só não é usado**: `Product.isFeatured` (`models/product.dart`) e `ProductService.featuredProducts` (`services/product_service.dart`) — a API já retorna `isFeatured` por produto, mas o getter nunca é chamado em nenhuma tela |
| `lib/services/order_service.dart` (`_orderFromJson`) | `imageUrl` fixo (`assets/images/paes_artesanais.jpeg`) para **todo** item de pedido, independente do produto real | `orders_screen.dart`, `order_detail_screen.dart` | ⚠️ Depende do backend: `GET /api/orders/user/{id}` não retorna imagem do produto no item do pedido — precisa estender o DTO |
| `lib/models/subscription_plan.dart` (`fromJson`) | Mesmo fallback fixo `paes_artesanais.jpeg` para item de assinatura ativa | `plan_details_screen.dart`, `plans_screen.dart` | ⚠️ Depende do backend: `GET /api/subscriptions/user/{id}` não retorna imagem — contraste: `SubscriptionTemplateProduct` (`subscription_template.dart`) já lê `imageUrl` real do backend corretamente, então o backend sabe fazer isso, só falta no endpoint de assinatura ativa |
| `assets/config/client_config.json` | Config de white-label (nome do app, cores, textos de splash) declarada no `pubspec.yaml` mas **nunca lida em nenhum lugar de `lib/`** | Nenhuma tela — arquivo morto | N/A — ou termina de ligar ou remove |

**Verificado e descartado** (parecia estático mas é legítimo, não é gap de API): métodos de pagamento e dias da semana em `checkout_screen.dart`/`plans_screen.dart` (enums de UI, sem endpoint equivalente), delay de `chat_screen.dart` (só scroll, não resposta fake), delay de `splash_screen.dart` (tempo mínimo de exibição, não simula rede). Também não há mais nenhum service/provider mock antigo (`api_service.dart`, `laravel_api_service.dart` etc. não existem — migração de fato removeu o código antigo, conforme `MIGRACAO.md`).

**Achados adicionais:**
- `MIGRACAO.md` já documenta oficialmente as limitações de imagem em pedidos/assinaturas (item 5 desta lista) como "conhecidas", mas **não menciona** categorias, descontos ou o carrossel de destaques — esses três ficaram de fora do escopo da migração e nunca foram revisitados.
- Bug potencial no gap de categorias: as strings de categoria hardcoded em `category_item.dart` (`'Pães'`, `'Bolos'`, `'Salgados'`, `'Bebidas'`, `'Doces'`, `'Lanches'`) são usadas para filtrar produtos ao tocar num card da home; se não baterem exatamente com as categorias reais vindas da API, o toque leva a uma lista vazia silenciosamente.
- Assets órfãos sem nenhuma referência em código: `assets/images/bolo_de_chocolate.jpeg`, `assets/images/categories/catgeria_bolos_caseiros.jpg` (nome com typo), `assets/images/descontos/descontos_bolos.jpg`.

**Prioridade sugerida de correção:**
1. **Carrossel de destaques → usar `ProductService.featuredProducts`** (menor esforço: já existe tudo, é só trocar a fonte de dados na `home_screen.dart`).
2. **Categorias → consumir `GET /api/categories`** (endpoint já existe; resolve também o risco de strings desalinhadas).
3. **Imagens em pedidos/assinaturas → exigem mudança no backend** (adicionar `imageUrl` ao DTO de item de pedido e de assinatura ativa, espelhando o que já existe em `SubscriptionTemplateProduct`).
4. **Descontos → decisão de produto**: manter estático (é conteúdo de marketing, pode ser aceitável) ou criar endpoint real no backend se promoções devem refletir dados reais.

## Resumo e pontos de atenção

1. **A divisão de responsabilidades entre os dois clientes está, no geral, correta e completa.** Tudo que é admin-only (`/api/admin/billing/*`, `/api/admin/dashboard/*`, `/api/admin/users`, `/api/admin/chat-messages/*`, `/api/admin/subscription-invoices/*`, `/api/admin/categories/*`, `/api/admin/products/*` exceto GET, `/api/admin/orders/*` exceto detail) é consumido exclusivamente pelo painel Next.js. Tudo que é cliente-facing (`register`, `users/me`, pedidos do cliente, assinaturas do cliente, chat do cliente, fidelidade) é consumido exclusivamente pelo app Flutter — nenhum vazamento cruzado.

2. **Único gap real de recurso ainda não implementado em nenhuma UI:** `GET /api/categories` (endpoint público de categorias). O app usa lista hardcoded (`category_item.dart`); o admin também não usa esse endpoint público — ele gerencia categorias via `/api/admin/categories`, mas o CRUD já é lido de volta ali mesmo, então não é um gap do admin. O gap é só do app: se o admin criar/editar categorias, o app continua mostrando a lista estática. **Este é o achado mais acionável desta análise.**

3. **Dois endpoints admin "de detalhe" existem na API mas não são chamados por ninguém — efetivamente código morto do ponto de vista de consumo:**
   - `GET /api/admin/orders/{orderId}` — o modal de detalhe do pedido no admin reaproveita o item já carregado na listagem.
   - `GET /api/admin/subscription-templates/{id}` — o modal de edição de template no admin reaproveita o item já carregado na listagem.
   - Isso funciona hoje porque a lista já traz os dados completos, mas quebra o modelo "buscar detalhe sob demanda" — se a resposta de detalhe algum dia divergir do item de lista (campos extras, dados de auditoria), a UI não vai perceber.

4. **Outros endpoints não usados por nenhum cliente (gaps "por id" do lado cliente/Flutter), sem contraparte no admin porque são escopo de cliente:**
   - `GET /api/products/category/{id}` — nem app nem admin usam; ambos filtram client-side.
   - `GET /api/orders/{orderId}` — Flutter não usa (reaproveita objeto local); não é escopo do admin (que tem seu próprio `/api/admin/orders/{orderId}`, também não usado — ver item 3).
   - `GET /api/subscriptions/{id}` e `GET /api/subscription-templates/{id}` — apenas Flutter tem escopo para esses, e não usa.

5. **Assimetria de logout:** o app chama `POST /api/logout` de verdade; o admin faz logout **apenas local** (limpa cookie e redireciona), sem chamar a API. Vale confirmar se isso é intencional (ex.: sessão do admin não precisa de invalidação server-side) ou se é uma lacuna a fechar.

6. **Nenhum endpoint `DELETE` é chamado pelo app Flutter** — `ApiClient` do app nem possui um helper `delete()`. O admin, em contrapartida, tem `apiDelete` e o usa para categorias (`DELETE /api/admin/categories/{id}`); produtos usam PUT como "desativar" em vez de DELETE físico.

7. **Mapas de serviço/API client, para referência:**
   - App (`lib/services/`): `auth_service.dart`, `product_service.dart`, `order_service.dart`, `subscription_service.dart`, `chat_service.dart`, `loyalty_service.dart`, `cart_service.dart` (carrinho 100% local, `SharedPreferences`, sem API).
   - Admin: wrapper único `lib/api.ts` (`apiFetch`/`apiGet`/`apiPost`/`apiPut`/`apiDelete`), sessão em `lib/auth.ts` (cookie `padaria_admin_session`), hook genérico `hooks/useFetch.ts` usado por todas as páginas, `contexts/AuthContext.tsx` para login. Sem axios, sem `fetch()` avulso fora do wrapper. Páginas relevantes: `app/(painel)/{categorias,produtos,pedidos,assinaturas,faturamento,chat,clientes,dashboard}/page.tsx`. Nenhuma página usa dados mockados — todas estão de fato ligadas à API.
