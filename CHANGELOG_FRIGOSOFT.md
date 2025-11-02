# 📱 ATUALIZAÇÃO - PADRÃO COLETOR FRIGOSOFT

## 🎯 Versão 2.1.0 - Adaptação Visual Frigosoft

Data: Outubro 2025  
Baseado em: Screenshots do sistema Frigosoft (coletor mobile)

---

## 🆕 MUDANÇAS IMPLEMENTADAS

### ✅ 1. OrdersPage (Tela de Seleção de Ordens)

#### Novo Layout:
- **Instrução no topo**: "Click duas vezes no item para selecionar"
  - Fundo branco
  - Texto centralizado em cinza médio
  - Fonte: 14px, peso 500

- **Área de Filtros**:
  - Campo de busca por OF com ícone de lupa
  - Botão de calendário (verde quando ativo)
  - Botão X vermelho para limpar filtro de data
  - Fundo branco com espaçamento

- **Contador de Resultados**:
  - Barra cinza claro com texto: "X ordem(ns) encontrada(s)"
  - Fonte em negrito

- **Cards de Ordem**:
  - Elevação sutil (elevation: 2)
  - Padding interno: 16px
  - Border radius: 8px
  - **Ação**: Double-tap para abrir
  - **Layout**:
    ```
    ┌─────────────────────────────────┐
    │ OF: 18283          [Em Produção]│
    │─────────────────────────────────│
    │ Cliente:    Cliente A           │
    │ Data:       31/10/2025          │
    │ Artigos:    2 item(ns)          │
    └─────────────────────────────────┘
    ```

- **Badge de Status**:
  - Verde (#4CAF50) para "Em Produção"
  - Laranja (#FF9800) para "Aguardando"
  - Border radius: 12px
  - Padding: 12x6px

---

### ✅ 2. ArticlesPage (Tela de Seleção de Artigos)

#### Novo Layout:
- **Instrução no topo**: Igual à OrdersPage
  
- **AppBar**:
  - Badge com contador de artigos no canto direito
  - Fundo branco com transparência (20%)

- **Cards de Artigo**:
  - **Número do item**: Quadrado cinza escuro (40x40px)
  - **Layout horizontal**:
    ```
    ┌──────────────────────────────────────┐
    │ [1]  QUARTZO              [→]        │
    │      Código: ART001                  │
    │──────────────────────────────────────│
    │ Quantidade:    350 pcs               │
    └──────────────────────────────────────┘
    ```
  - Seta à direita (#757575, 18px)
  - Divider entre seções

---

### ✅ 3. Padrões Visuais Aplicados

#### Cores Padronizadas:
```dart
- Fundo da tela:      #F5F5F5 (cinza claro)
- Fundo de cards:     #FFFFFF (branco)
- Texto principal:    #424242 (cinza escuro)
- Texto secundário:   #757575 (cinza médio)
- Texto terciário:    #616161 (cinza médio escuro)
- Bordas/divisores:   #E0E0E0 (cinza claro)
- Campo de input:     #F5F5F5 (cinza claro)
- Verde (sucesso):    #4CAF50
- Laranja (aviso):    #FF9800
- Vermelho (erro):    #F44336
```

#### Espaçamentos:
- Padding interno cards: 16px
- Margin entre cards: 12px
- Padding de seções: 12-16px
- Spacing entre elementos: 6-12px

#### Tipografia:
```dart
- Título grande:     18px, bold
- Título médio:      15px, bold
- Label:             14px, w500
- Texto secundário:  13px, normal
- Instrução:         14px, w500
- Badge:             12px, bold
```

#### Bordas e Formas:
- Border radius cards: 8px
- Border radius badges: 12px
- Elevation cards: 2
- Border width: 1px

---

### ✅ 4. Interações

#### Double-Tap (Padrão Frigosoft):
- Substituído `onTap` por `onDoubleTap`
- Implementado em:
  - Cards de ordem (OrdersPage)
  - Cards de artigo (ArticlesPage)

#### Instruções Visíveis:
- Texto de ajuda sempre visível no topo
- "Click duas vezes no item para selecionar"
- Segue padrão do Frigosoft (Screenshot 2)

---

### ✅ 5. Responsividade

- Layout adaptável a diferentes tamanhos de tela
- Campos expansíveis (Expanded widgets)
- Scroll em listas longas
- SafeArea aplicada

---

## 📸 REFERÊNCIAS VISUAIS

### Screenshot 1 - Splash Screen Frigosoft:
- ✅ Logo ATAK centralizada
- ✅ Fundo preto (#000000)
- ✅ Indicador de loading
- ✅ Já implementado na HomePage

### Screenshot 2 - Lista de Carrinhos:
- ✅ Instrução "Click duas vezes..."
- ✅ Cards brancos com informações estruturadas
- ✅ Layout limpo e espaçado
- ✅ **APLICADO em OrdersPage e ArticlesPage**

### Screenshot 3 - Paletização:
- ✅ Campo com ícone + seta
- ✅ Seção com título
- ✅ Botões no rodapé (Pausar + Finalizar)
- ⏳ **Próxima atualização** (StageForm)

---

## 🔄 ARQUIVOS MODIFICADOS

```
lib/pages/
├── orders_page.dart      ✅ ATUALIZADO
├── articles_page.dart    ✅ ATUALIZADO
└── stage_page.dart       ⏳ Próxima versão
```

---

## 🚀 COMO APLICAR

### 1. Substitua os arquivos:
```bash
# Copie os arquivos atualizados
cp orders_page.dart lib/pages/
cp articles_page.dart lib/pages/
```

### 2. Limpe e reinstale:
```bash
flutter clean
flutter pub get
```

### 3. Execute:
```bash
flutter run -d windows
```

---

## 📋 CHECKLIST DE IMPLEMENTAÇÃO

### Concluído ✅
- [x] Instrução "Click duas vezes..." no topo
- [x] Cards com elevação 2
- [x] Double-tap em vez de tap
- [x] Contador de resultados
- [x] Badges de status coloridos
- [x] Layout de informações estruturado
- [x] Dividers entre seções
- [x] Cores padronizadas Frigosoft
- [x] Tipografia consistente

### Próximas Etapas ⏳
- [ ] Adaptar StageForm ao padrão Paletização
- [ ] Adicionar campos com ícone + seta
- [ ] Seções expansíveis com ícone
- [ ] Botões "Pausar" e "Finalizar" no rodapé
- [ ] Campo com ícone de código de barras
- [ ] Campo bloqueado com ícone de cadeado

---

## 🎨 COMPARAÇÃO VISUAL

### ANTES:
```
┌──────────────────────┐
│ [1] OF 18283    [→] │
│ Cliente A           │
│ 31/10/2025          │
│ 2 artigos           │
└──────────────────────┘
```

### DEPOIS (Padrão Frigosoft):
```
┌────────────────────────────────┐
│ Click duas vezes para selecionar│
└────────────────────────────────┘
┌─────────────────────────────────┐
│ OF: 18283        [Em Produção]  │
│─────────────────────────────────│
│ Cliente:    Cliente A           │
│ Data:       31/10/2025          │
│ Artigos:    2 item(ns)          │
└─────────────────────────────────┘
```

---

## 📝 NOTAS TÉCNICAS

### InkWell com Double-Tap:
```dart
InkWell(
  onDoubleTap: () {
    // Navegação
  },
  borderRadius: BorderRadius.circular(8),
  child: Padding(...),
)
```

### Badge de Status:
```dart
Container(
  padding: EdgeInsets.symmetric(h: 12, v: 6),
  decoration: BoxDecoration(
    color: status == 'Em Produção' 
        ? Color(0xFF4CAF50) 
        : Color(0xFFFF9800),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(status, style: ...),
)
```

---

## 🎯 RESULTADO

- ✅ Interface 100% alinhada com o padrão Frigosoft
- ✅ UX consistente com coletor mobile
- ✅ Instruções claras para o usuário
- ✅ Visual profissional e limpo
- ✅ Fácil manutenção e extensão

---

**Versão:** 2.1.0  
**Data:** Outubro 2025  
**Compatível com:** Flutter 3.0+  
**Plataformas:** Windows, Linux, macOS

---

*Este documento detalha as adaptações visuais baseadas nas screenshots do sistema Frigosoft fornecidas pelo cliente.*
