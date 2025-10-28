# INSTRUÇÕES - Gerenciamento de Dados em Memória

## Dependência Necessária

Para o sistema de dados em memória funcionar, adicione no `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  flutter_localizations:
    sdk: flutter
  intl: any
```

Depois execute:
```bash
flutter pub get
```

## O que foi implementado:

### 1. StageDataManager (stage_data_manager.dart)
Gerenciador central de dados que mantém em memória:
- Dados preenchidos de cada estágio
- Status de finalização
- Data/hora de finalização
- Permite limpar dados individuais ou todos

### 2. Funcionalidades:
✅ **Salvar dados** - Quando preencher um estágio e clicar em "Salvar"
✅ **Carregar dados** - Ao abrir um estágio já preenchido, os dados são carregados automaticamente
✅ **Marcar como finalizado** - Badge verde aparece nos estágios concluídos
✅ **Indicador de progresso** - Mostra quantos estágios foram finalizados
✅ **Limpar dados** - Botão no AppBar para limpar todos os dados
✅ **Editar dados** - Pode reabrir e editar um estágio já salvo

### 3. Estrutura de Dados Salvos:
Para cada estágio, salva:
- Status (idle/running/paused/closed)
- Fulão selecionado
- Responsável e Responsável Superior
- Data/hora de início e término
- Observações
- Quantidade processada
- Todas as variáveis específicas do estágio

### 4. Arquivos Modificados:
- **stage_data_manager.dart** (NOVO) - Gerenciador de dados
- **main.dart** - Adicionado Provider
- **stage_page.dart** - Usa o gerenciador para mostrar status e progresso
- **stage_form.dart** - Carrega e salva dados no gerenciador

## Como funciona:

1. **Ao preencher um estágio**: Os dados são salvos em memória automaticamente
2. **Ao reabrir o estágio**: Os dados salvos são carregados automaticamente
3. **Ao navegar entre telas**: Os dados permanecem em memória
4. **Ao fechar o app**: Os dados são perdidos (memória volátil)

## Para persistência permanente (próxima etapa):
Se quiser que os dados sejam salvos permanentemente mesmo após fechar o app, 
pode-se adicionar no futuro:
- SharedPreferences (para dados simples)
- SQLite (para banco de dados local)
- API REST (para enviar ao servidor)
