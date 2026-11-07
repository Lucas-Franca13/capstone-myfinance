# MyFinance — Capstone A3, entrega final

## 1. Identificação

- **Aplicativo:** MyFinance
- **Squad:** FinTrack Squad
- **Contato do grupo (informado na Etapa 2):** 72401362@aluno.faculdadecotemig.br.

| Integrante | Matrícula |
|---|---|
| Bernardo Santos Magalhaes | 72400188 |
| João Victor Amaro de Araújo | 72400110 |
| Lucas Filipe França Nunes | 72401362 |
| Lucas Henrique Albergaria | 72401400 |
| Vitor de Oliveira Costa e Silva | 72200162 |

## 2. Projeto

O MyFinance é um aplicativo Flutter de acompanhamento financeiro pessoal.
Seu público é quem deseja registrar receitas e despesas e acompanhar algumas cotações.
A tela inicial reúne saldo calculado das transações cadastradas e acesso às funções.
O formulário de nova transação valida os campos e grava a movimentação no aparelho.
A tela de mercado consulta a AwesomeAPI e lista dólar, euro e bitcoin em reais.
Ao tocar numa cotação, o usuário vê detalhes e pode favoritar o ativo.
A tela de configurações guarda favoritos, opção de ocultar saldo e orçamento mensal.
O tema claro ou escuro é alternado pelo switch no topo das telas ou pela opção “Tema escuro” nas preferências; a escolha fica salva.
O extrato mostra as transações registradas, filtra receitas e despesas e abre o detalhe de cada uma.
Uma transação pode ser excluída deslizando o item ou pelo detalhe, com opção de desfazer.
Telas adicionais de documentos, investimentos e perfil ilustram a evolução do produto.

## 3. Requisitos da A3

| Requisito | Implementação |
|---|---|
| Quatro ou mais telas e navegação | Início, formulário, mercado, detalhe da cotação, configurações, extrato e detalhe da transação. Formulário e detalhes usam `Navigator.push/pop`; o caminho Início → formulário → mercado → detalhe → favoritos também abre rotas. As quatro áreas principais usam uma única barra em pílula com transição animada. |
| API REST | `http.Client` injetado em `QuoteRepository`; GET assíncrono de três cotações na AwesomeAPI. |
| Carregamento e erro | Indicador de progresso, mensagem de falha e botão “Tentar novamente”; atualização por gesto de puxar. |
| Formulário validado | `Form`, `TextFormField`, campos obrigatórios e valor positivo. A transação validada é salva. |
| Lista dinâmica | `ListView.builder` renderiza o resultado da API na tela de mercado. |
| Persistência | `SharedPreferencesAsync` guarda favoritos, saldo oculto, tema, orçamento e transações, incluindo exclusões; os valores são lidos ao iniciar o app. |
| Provider | `FinanceController` e `MarketController` são `ChangeNotifier` fornecidos por `MultiProvider`. Telas não fazem requisições HTTP nem acessam a preferência diretamente. |
| Execução completa | Caminhos de sucesso, validação, erro da API, persistência, exclusão com desfazer, filtro do extrato e tema escuro cobertos pelos testes automatizados. |

## 4. API

- **Fornecedor:** [AwesomeAPI — API de moedas](https://docs.awesomeapi.com.br/api-de-moedas).
- **Base:** `https://economia.awesomeapi.com.br`
- **Endpoint usado:** `GET /json/last/USD-BRL,EUR-BRL,BTC-BRL`
- **Acesso:** público para este uso; sem chave e sem login no app.
- **Dados utilizados:** `bid`, `pctChange` e `timestamp` de `USDBRL`, `EURBRL` e `BTCBRL`.
- **Comportamento:** a API pode usar cache; o app mostra o horário informado na resposta. Sem conexão, mostra erro e permite nova tentativa. As cotações não são recomendações de investimento.
- **Documentação no app:** a tela de detalhe da cotação abre a documentação da API no navegador com `url_launcher`.

## 5. Como executar

- **Versão usada na verificação:** Flutter 3.44.5 / Dart 3.12.2.
- **Plataformas do projeto:** Android, iOS, macOS, Linux, Windows e Web. A conferência visual da entrega foi feita em iOS; a permissão de internet foi adicionada ao Android.

```sh
flutter pub get
flutter run
```

Para verificar:

```sh
flutter analyze
flutter test
```

Escolha um dispositivo conectado com `flutter devices` ou use `flutter run -d <id>`.

No Windows, o Flutter exige o Modo de Desenvolvedor ativo para compilar projetos com plugins (`start ms-settings:developers`).

## 6. Backend local

Não há backend local. O app acessa diretamente a API pública por HTTPS. As transações e preferências ficam apenas no armazenamento local do dispositivo.

## 7. Organização do código

- `lib/screens/`: telas e navegação.
- `lib/widgets/`: componentes visuais reutilizáveis, barra em pílula e ação de excluir com desfazer.
- `lib/app_theme.dart`: paleta clara e escura (`ThemeExtension`) e tema do Material.
- `lib/controllers/`: estado de mercado e finanças com Provider.
- `lib/services/`: cliente HTTP e acesso ao armazenamento local.
- `lib/market_data.dart` e `lib/demo_data.dart`: modelos de cotação e transação.
- `test/widget_test.dart`: testes do contrato da API, estados de interface, exclusão, filtro, tema e persistência com armazenamento simulado.

## 8. Observações e entrega

As telas de documentos, investimentos e perfil contêm exemplos identificados na interface; não fazem upload de arquivos nem indicam aplicações financeiras. Os dados de movimentações inseridos pelo usuário são reais para aquela instalação, mas `SharedPreferences` não é armazenamento criptografado; não insira documentos ou informações financeiras sensíveis nesta versão acadêmica. Não existe sincronização entre dispositivos.

Itens bônus do guia presentes no app: tema claro/escuro com switch no topo das telas e escolha salva, `url_launcher` para abrir a documentação da API e animações na barra em pílula, na troca de abas e na exclusão por deslize.

O pacote final chama-se `Capstone_A3_FinTrackSquad.zip`. Ele exclui `build/`, `.dart_tool/`, arquivos locais de IDE e configurações geradas.
