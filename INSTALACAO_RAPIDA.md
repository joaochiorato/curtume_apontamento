# 🚀 GUIA RÁPIDO - Instalação do Logo ATAK

## ⚡ 3 PASSOS SIMPLES

### 1️⃣ Copiar Arquivos
```bash
# Copiar logo
cp assets/images/logo_atak.png SEU_PROJETO/assets/images/

# Copiar home_page.dart
cp lib/pages/home_page.dart SEU_PROJETO/lib/pages/
```

### 2️⃣ Editar pubspec.yaml
Adicione no final do arquivo:
```yaml
flutter:
  assets:
    - assets/images/logo_atak.png
```

### 3️⃣ Rodar
```bash
flutter pub get
flutter run
```

---

## ✅ PRONTO!

O logo ATAK agora aparece na tela inicial!

---

## 🐛 Se der erro:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 Verificar Estrutura:

```
SEU_PROJETO/
├── assets/
│   └── images/
│       └── logo_atak.png  ← Deve existir aqui
├── lib/
│   └── pages/
│       └── home_page.dart ← Deve existir aqui
└── pubspec.yaml           ← Deve ter referência ao logo
```

---

**É só isso!** 🎨
