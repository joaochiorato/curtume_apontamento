# 🧪 BOTÃO QUÍMICOS - Lançamento de Produtos

## 🎯 NOVA FUNCIONALIDADE

Botão "Químicos" ao lado do campo Fulão para lançar as quantidades de produtos químicos utilizados no processo!

---

## 📸 VISUAL DO BOTÃO

### Posição:
```
┌──────────────────────────────────────────────┐
│ Fulão                    │  [🧪 Químicos]   │
│ ▼ Fulão 1               │    0/6           │
└──────────────────────────────────────────────┘
       ↑ Dropdown              ↑ Botão novo
```

### Estados do Botão:

**Sem químicos informados:**
```
┌─────────────┐
│ 🧪 Químicos │  ← Cinza azulado
└─────────────┘
```

**Com químicos informados:**
```
┌─────────────┐
│ 🧪 Químicos │  ← VERDE
│    3/6      │  ← Contador
└─────────────┘
```

---

## 🧪 LISTA DE QUÍMICOS

Ao clicar no botão, abre um dialog com os seguintes produtos:

1. **Cal virgem (hidróxido de cálcio)** - kg
2. **Sulfeto de sódio (Na₂S)** - kg
3. **Hidrossulfeto de sódio (NaHS)** - kg
4. **Desulfex, EcoLime, Biosafe** - kg
5. **Tensoativo / umectante** - L
6. **Agente sequestrante** - L

---

## 📱 DIALOG DE QUÍMICOS

### Layout:
```
╔══════════════════════════════════════╗
║  🧪 Químicos Utilizados          ✕  ║
╠══════════════════════════════════════╣
║                                      ║
║  Cal virgem (hidróxido de cálcio)   ║
║  ┌────────────────────────────────┐ ║
║  │ Informar quantidade       ✏️   │ ║
║  └────────────────────────────────┘ ║
║                                      ║
║  Sulfeto de sódio (Na₂S)            ║
║  ┌────────────────────────────────┐ ║
║  │ 25 kg                     ✏️   │ ║ ← Preenchido
║  └────────────────────────────────┘ ║
║                                      ║
║  Hidrossulfeto de sódio (NaHS)      ║
║  ┌────────────────────────────────┐ ║
║  │ Informar quantidade       ✏️   │ ║
║  └────────────────────────────────┘ ║
║                                      ║
║  ...                                 ║
║                                      ║
╠══════════════════════════════════════╣
║  [ ✓ Concluir ]                     ║
╚══════════════════════════════════════╝
```

---

## ⚙️ FUNCIONAMENTO

### 1️⃣ Clicar no Botão "Químicos"
- Abre dialog com lista de produtos
- Só funciona se o processo estiver iniciado

### 2️⃣ Informar Quantidades
- Clicar em cada produto
- Abre numpad customizado
- Digitar quantidade
- Confirmar

### 3️⃣ Visualizar Progresso
- Contador no botão (ex: 3/6)
- Botão fica verde quando tem químicos
- Campos preenchidos ficam verdes

### 4️⃣ Salvar Dados
- Ao salvar o formulário
- Químicos são salvos junto
- Recarrega automaticamente na próxima abertura

---

## 🎨 CORES E ESTADOS

### Botão Químicos:

| Estado | Cor | Texto |
|--------|-----|-------|
| Sem dados | Cinza (#546E7A) | Químicos |
| Com dados | Verde (#4CAF50) | Químicos + 3/6 |

### Campos no Dialog:

| Estado | Borda | Fundo |
|--------|-------|-------|
| Vazio | Preta | Cinza claro |
| Preenchido | Verde | Verde 5% |

---

## 📊 DADOS SALVOS

Os dados dos químicos são salvos no formato:

```json
{
  "status": "closed",
  "fulao": 1,
  "responsavel": "Ana",
  "variables": { ... },
  "quimicos": {
    "Cal virgem (hidróxido de cálcio)": "25",
    "Sulfeto de sódio (Na₂S)": "30",
    "Tensoativo / umectante": "5"
  }
}
```

---

## ✨ FUNCIONALIDADES

### ✅ Botão Inteligente
- Mostra contador de químicos informados
- Muda de cor quando tem dados
- Desabilitado se processo não iniciado

### ✅ Dialog Completo
- Lista todos os 6 químicos
- Rolagem se necessário
- Numpad customizado
- Validação de valores

### ✅ Persistência de Dados
- Salva junto com o formulário
- Recarrega automaticamente
- Mantém os valores informados

### ✅ Visual Integrado
- Mesmo estilo das variáveis
- Cores consistentes
- UX intuitivo

---

## 🚀 INSTALAÇÃO

### 1️⃣ Extrair na Raiz

```bash
cd C:\Projetos\Final\curtume_apontamento_final
unzip -o botao_quimicos.zip
```

### 2️⃣ Rodar

```bash
flutter run
```

---

## 📁 ARQUIVO SUBSTITUÍDO

```
lib/
└── widgets/
    └── stage_form.dart  ← Versão com botão Químicos
```

---

## 🔄 COMPATIBILIDADE

- ✅ Mantém todas as funcionalidades anteriores
- ✅ Indicadores melhorados das variáveis
- ✅ Botão Químicos integrado
- ✅ Persistência de dados
- ✅ Numpad customizado

---

## 💡 DICAS DE USO

### Para Informar Químicos:
1. Iniciar o processo
2. Clicar no botão "Químicos"
3. Informar as quantidades
4. Clicar em "Concluir"
5. Continuar preenchendo o resto

### Para Editar:
1. Clicar novamente no botão "Químicos"
2. Alterar os valores desejados
3. Clicar em "Concluir"

### Para Ver Quantos Foram Informados:
- Olhar o contador no botão (ex: 3/6)
- Verde = tem dados
- Cinza = sem dados

---

## 📝 EXEMPLO COMPLETO

### Fluxo de Trabalho:

```
1. [Iniciar] ← Clicar
2. [Fulão] → Selecionar Fulão 1
3. [Químicos] ← Clicar
   ├─ Cal virgem: 25 kg
   ├─ Sulfeto de sódio: 30 kg
   └─ Tensoativo: 5 L
4. [Concluir] ← Fechar dialog
5. [Botão mostra: 3/6] ← Verde
6. Preencher resto do formulário...
7. [Salvar]
```

---

## ✅ BENEFÍCIOS

✅ **Organizado** - Tudo em um lugar  
✅ **Rápido** - Numpad customizado  
✅ **Visual** - Contador mostra progresso  
✅ **Persistente** - Não perde dados  
✅ **Integrado** - Mesma UX das variáveis  
✅ **Profissional** - Interface moderna  

---

**Agora você pode controlar os químicos utilizados no processo!** 🧪

Data: Outubro 2025  
Versão: 2.2.0 (Botão Químicos)  
Tamanho: 1 arquivo (~35 KB)
