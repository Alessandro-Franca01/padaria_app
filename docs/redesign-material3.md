# Redesign UI — Tema Material 3

Branch: `feat/material3-theme-redesign` · PR: https://github.com/Alessandro-Franca01/padaria_app/pull/new/feat/material3-theme-redesign

## O que foi feito

### Tema centralizado
- Criado `lib/theme/app_theme.dart`:
  - `ColorScheme.fromSeed` com semente âmbar/caramelo (`AppColors.seed = 0xFFB5651D`), Material 3 (`useMaterial3: true`).
  - Superfícies neutras e claras (visual "app de delivery moderno"), em vez do creme/marrom pesado.
  - Temas padronizados para: `AppBarTheme`, `CardTheme`, `FilledButtonTheme`, `ElevatedButtonTheme`, `OutlinedButtonTheme`, `TextButtonTheme`, `InputDecorationTheme`, `ChipTheme`, `NavigationBarTheme`, `SnackBarTheme`, `DividerTheme`.
  - Tokens auxiliares: `AppColors.success/successContainer/warning/warningContainer` (estados semânticos fora do `ColorScheme` padrão) e `AppRadii.sm/md/lg`.
- `lib/main.dart`: removido o tema inline Material 2 (`primarySwatch: Colors.brown`); aplicado `AppTheme.light`; `debugShowCheckedModeBanner: false`.

### Telas atualizadas (todas as 15)
Splash, Login, Register, Home, Products, Product Detail, Cart, Checkout, Orders, Order Detail, Order Confirmation, Plans, Plan Details, Subscription Plans List, Chat, Profile.

Mudanças recorrentes em quase todas:
- Removidas cores cravadas (`Colors.brown[...]`, `Colors.grey[...]`, `Colors.green`, `Colors.red`, `Colors.orange` soltos) em favor de `Theme.of(context).colorScheme.*` ou `AppColors.*`.
- `Card` com `elevation`/`shape` manuais → herdando o `CardTheme` do tema.
- `ElevatedButton` com `style` manual → `FilledButton` / `OutlinedButton` do tema (menos código, visual consistente).
- `AppBar` com `backgroundColor: Colors.brown` removido (herda do tema).

### Bugs corrigidos
- **Botões com `backgroundColor: Colors.white30`** (ficavam translúcidos/quase invisíveis) — estavam em pontos críticos de conversão:
  - Home → "Ver Todos os Produtos"
  - Carrinho → "Finalizar Compra"
  - Checkout → "Finalizar Pedido"
  - Plans → "Escolher" (horário) e "Usar endereço do perfil"
- Order Confirmation: botão "Ver Meus Pedidos" tinha texto âmbar sobre fundo marrom (contraste ruim) → agora `FilledButton` padrão do tema.

### Navegação
- `BottomNavigationBar` (Material 2, cores cravadas, badges manuais via `Stack`/`Positioned`) → **`NavigationBar`** (Material 3) com **`Badge`** nativo para contadores de pedidos ativos e itens do carrinho.

### Componentes específicos
- **Login**: tela reorganizada (ícone em círculo com `primaryContainer`, hierarquia de título/subtítulo), botão de entrar com spinner usando `colorScheme.onPrimary`.
- **Home**: seções duplicadas de título removidas (ex.: "Nossas Especialidades" + "Categorias" viraram uma seção só), carrossel de destaques ganhou overlay de gradiente + título sobre a imagem.
- **Chat**: bolhas de mensagem com cauda assimétrica (estilo app de mensagens), campo de envio com `SafeArea`, botão de enviar `IconButton.filled`.
- **Cart**: item card com controles de quantidade `IconButton.filledTonal`/`filled`, empty state redesenhado com ícone em círculo.
- **Checkout**: os 6 cards de seção (resumo, endereço, data/hora, recorrência, pagamento, fidelidade, observações) padronizados; `showDatePicker`/`showTimePicker` não sobrescrevem mais o tema com marrom cravado — herdam o `AppTheme.light`.
- **Profile**: avatar com `primaryContainer`, botão salvar `FilledButton.icon`.

## O que ainda precisa ser testado

> Nada foi testado em dispositivo/emulador ainda além da checagem visual feita pelo usuário. Este checklist serve para a próxima rodada de testes manuais.

### Fluxo de autenticação
- [ ] Login com credenciais válidas → navega para Home
- [ ] Login com credenciais inválidas → SnackBar de erro aparece com a cor certa (`colorScheme.error`)
- [ ] Cadastro (Register): validação de campos, aceite de termos obrigatório, SnackBar de erro/sucesso
- [ ] Logout a partir do Profile → volta para Login

### Navegação principal (Home)
- [ ] `NavigationBar` (Início/Planos/Pedidos/Carrinho) troca de aba corretamente
- [ ] Badge de pedidos ativos aparece/some conforme pedidos mudam de status
- [ ] Badge do carrinho aparece/some conforme itens são adicionados/removidos
- [ ] Carrossel de destaques rola automaticamente e o texto sobre gradiente está legível
- [ ] Botão "Ver Todos os Produtos" navega e está visualmente sólido (bug do `white30` corrigido)
- [ ] Grid de categorias navega para Products filtrado

### Produtos
- [ ] Listagem carrega, filtro por categoria (chips) funciona
- [ ] Busca (search delegate) retorna sugestões e resultados
- [ ] Card de produto: botão de adicionar ao carrinho funciona quando disponível e fica desabilitado quando indisponível
- [ ] Detalhe do produto: seletor de quantidade, campo de observações, "Adicionar ao Carrinho" e "Ver Carrinho" (com badge) funcionam

### Carrinho
- [ ] Item: alterar quantidade, remover item, adicionar/editar observações
- [ ] Empty state aparece quando carrinho vazio, botão "Continuar Comprando" navega
- [ ] "Limpar carrinho" (diálogo de confirmação) funciona
- [ ] Botão "Finalizar Compra" **visualmente sólido** (não translúcido) e bloqueia se não autenticado

### Checkout
- [ ] Resumo do pedido reflete itens do carrinho
- [ ] Endereço: alternar entre "usar cadastrado" e digitar novo
- [ ] Seleção de data e hora de entrega (verificar se o `DatePicker`/`TimePicker` está com as cores do tema, não mais marrom cravado)
- [ ] Pedido recorrente: ativar switch, selecionar dias da semana
- [ ] Forma de pagamento: seleção via radio
- [ ] Pontos de fidelidade exibidos corretamente
- [ ] Validações: SnackBars de aviso (data/hora, dias recorrentes, endereço) aparecem com a cor `AppColors.warning`
- [ ] Botão "Finalizar Pedido" **visualmente sólido**, estado de loading, navega para confirmação

### Confirmação e Pedidos
- [ ] Tela de confirmação exibe dados corretos do pedido e pontos ganhos
- [ ] Botões "Ver Meus Pedidos" e "Voltar ao Início" funcionam
- [ ] Aba Pedidos: tabs "Ativos"/"Histórico" filtram corretamente
- [ ] Pull-to-refresh atualiza a lista
- [ ] Card de pedido: cores de status (`_getStatusColor`) continuam corretas para todos os status
- [ ] Detalhe do pedido: cancelar pedido (diálogo + SnackBar de sucesso/erro), reordenar (pedidos concluídos), contato/suporte (diálogo)

### Assinaturas/Planos
- [ ] Lista de planos: catálogo de templates (scroll horizontal) e "Meus Planos"
- [ ] Criar plano: selecionar template, escolher produtos e quantidades, dias da semana, horário (`TimePicker` com tema correto), endereço (usar do perfil ou digitar)
- [ ] Switch "Plano ativo" funciona sem cor cravada
- [ ] Resumo do plano atualiza em tempo real
- [ ] Salvar plano: loading, navegação para detalhes, SnackBar de erro em caso de falha
- [ ] Editar plano existente: campos pré-preenchidos corretamente
- [ ] Detalhes do plano: botão de editar (ícone) e "Voltar"

### Chat
- [ ] Lista de conversas/mensagens carrega
- [ ] Enviar mensagem (botão e `onSubmitted` do teclado)
- [ ] Bolhas de mensagem: cor correta para usuário vs. padaria, texto legível
- [ ] Refresh manual (ícone) e pull-to-refresh

### Perfil
- [ ] Dados do usuário carregam nos campos (nome, telefone, endereço)
- [ ] Validação de campos obrigatórios
- [ ] Salvar alterações: loading, SnackBar de sucesso/erro
- [ ] Avatar com iniciais e pontos de fidelidade exibidos

### Geral / regressão visual
- [ ] Nenhum texto com contraste ruim (branco sobre claro, âmbar sobre marrom, etc.)
- [ ] Nenhum botão com aparência translúcida/"lavada"
- [ ] Consistência de cantos arredondados (`AppRadii`) entre cards, botões e inputs
- [ ] Testar em pelo menos um dispositivo Android real ou emulador com tema claro do sistema
- [ ] Rodar `flutter analyze` para conferir se não há erros novos (os avisos de `const` são pré-existentes e não bloqueiam)
