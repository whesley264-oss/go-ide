# PRD: Mobile Code Editor (Spck-like)

## 1. Introdução

Editor de código mobile completo estilo Spck/Acode para Android, com destaque de sintaxe multi-linguagem, auto-completar inteligente, suporte a arquivos locais e remotos (SFTP), terminal integrado para execução de código, e interface escura moderna otimizada para dispositivos 32-bit.

## 2. Objetivos

- Syntax highlighting para 20+ linguagens (Go, Python, JS, Java, C, Rust, etc.)
- Auto-completar e sugestões inteligentes
- File explorer com suporte a storage interno e externo
- Cliente SFTP integrado
- Terminal integrado para execução de código
- Interface escura estilo Spck/VSCode
- Suporte a dispositivos 32-bit
- Performance otimizada para mobile

## 3. User Stories

### US-001: Syntax Highlighting
**Descrição:** Como usuário, quero destaque de sintaxe colorido para poder ler código facilmente.

**Critérios:**
- [ ] Suporte a Go, Python, JavaScript, TypeScript, Java, C, C++, Rust, HTML, CSS, JSON, YAML, Markdown, SQL, Shell, PHP, Ruby, Swift, Kotlin
- [ ] Cores consistentes com tema escuro VSCode-like
- [ ] Line numbers visíveis
- [ ] Indentação visual

### US-002: Auto-completar
**Descrição:** Como usuário, quero sugestões de código para digitar mais rápido.

**Critérios:**
- [ ] Completar palavras do próprio arquivo
- [ ] Completar keywords da linguagem
- [ ] Mostrar popup de sugestões ao digitar
- [ ] Tab/Enter para selecionar sugestão

### US-003: File Explorer
**Descrição:** Como usuário, quero navegar e gerenciar arquivos/pastas.

**Critérios:**
- [ ] Árvore de diretórios expansível
- [ ] Criar/renomear/deletar arquivos e pastas
- [ ] Suporte a storage interno do app
- [ ] Suporte a pastas externas via file_picker
- [ ] Ícones diferenciados por tipo de arquivo

### US-004: SFTP Client
**Descrição:** Como usuário, quero conectar a servidores remotos via SFTP.

**Critérios:**
- [ ] Guardar conexões SSH/SFTP
- [ ] Navegar em diretórios remotos
- [ ] Upload/download de arquivos
- [ ] Editar arquivos remotos diretamente

### US-005: Terminal Integrado
**Descrição:** Como usuário, quero executar código direto do app.

**Critérios:**
- [ ] Terminal estilo xterm com scrollback
- [ ] Suporte a comandos Go (go run, go build)
- [ ] Input interativo
- [ ] Cores e output formatado

### US-006: Execution de Código
**Descrição:** Como usuário, quero executar meu código Go no dispositivo.

**Critérios:**
- [ ] Detectar linguagem automaticamente
- [ ] Rodar código Go via process_run/Dart FFIPara sistemas 32-bit
- [ ] Mostrar output em terminal
- [ ] Suporte a argumentos de linha de comando

## 4. Requisitos Funcionais

- FR-1: Editor com CodeField/CodeMirror baseado em flutter_code_editor ou re_editor
- FR-2: Syntax highlighting via highlight.js ou language_definition
- FR-3: Auto-completar com CompletionWindow
- FR-4: File explorer com tree_view
- FR-5: SFTP via dart-ssh ou similar
- FR-6: Terminal via xterm ou flutter_pty
- FR-7: Tema escuro customizado
- FR-8: Persistência de arquivos com path_provider
- FR-9: Storage de configurações com shared_preferences

## 5. Non-Goals

- Não é um debugger completo (breakpoints, step-by-step)
- Não é um cliente Git completo (apenas visualização)
- Não suporta projetos muito grandes (>10MB por arquivo)
- Não é um substituto de desktop IDE

## 6. Design

### Tema Escuro (Spck-like)
```
Background: #1E1E1E (editor), #252526 (sidebar), #333333 (panels)
Line numbers: #858585
Selection: #264F78
Keywords: #569CD6
Strings: #CE9178
Functions: #DCDCAA
Comments: #6A9955
Variables: #9CDCFE
Numbers: #B5CEA8
Operators: #D4D4D4
```

### Layout
```
┌─────────────────────────────────────────┐
│ [Barra de título com nome do arquivo]   │
├────────┬────────────────────────┬────────┤
│        │                        │        │
│ File   │     Editor de Código  │ Mais   │
│ Explorer│     com line numbers  │ Painis │
│        │                        │ (term, │
│        │                        │  git)  │
│        │                        │        │
├────────┴────────────────────────┴────────┤
│ Terminal / Output                       │
└─────────────────────────────────────────┘
```

## 7. Considerações Técnicas

- Usar flutter_code_editor ou re_editor para o editor base
- dart-ssh para SFTP
- xterm para terminal
- path_provider para storage
- shared_preferences para settings
- dart:io Process.start para execução de código
- Suporte a ARMv7 (32-bit)

## 8. Métricas de Sucesso

- Editor abre em <2 segundos
- Syntax highlighting renderiza sem lag
- Auto-complete responde em <100ms
- Arquivos abrem até 1MB suavemente
