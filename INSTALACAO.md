# 🔧 GUIA DE INSTALAÇÃO - Passo a Passo

## ⚠️ IMPORTANTE: Siga estes passos na ordem!

### 1️⃣ Adicionar dependência Provider

Abra o arquivo `pubspec.yaml` na raiz do seu projeto e adicione `provider`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  provider: ^6.1.1    # ← ADICIONE ESTA LINHA
  intl: any
```

### 2️⃣ Instalar as dependências

No terminal, execute:

```bash
flutter pub get
```

Aguarde a instalação terminar. Você deve ver algo como:
```
Resolving dependencies...
Got dependencies!
```

### 3️⃣ Limpar build anterior

```bash
flutter clean
```

### 4️⃣ Rodar o projeto

```bash
flutter run
```

---

## 🐛 Se ainda der erro:

### Erro de versão incompatível:

Se der erro de incompatibilidade, tente versões diferentes:

```yaml
provider: ^6.0.0
```

ou

```yaml
provider: ^5.0.0
```

### Erro de cache:

```bash
flutter pub cache repair
flutter clean
flutter pub get
flutter run
```

### Verificar versão do Flutter:

```bash
flutter --version
```

Se estiver usando Flutter muito antigo (< 3.0), atualize:

```bash
flutter upgrade
```

---

## ✅ Checklist de Instalação:

- [ ] Adicionei `provider: ^6.1.1` no pubspec.yaml
- [ ] Executei `flutter pub get`
- [ ] Executei `flutter clean`
- [ ] Tentei rodar com `flutter run`

---

## 📝 pubspec.yaml completo (exemplo):

Veja o arquivo `pubspec_exemplo.yaml` incluído no ZIP para referência completa.
